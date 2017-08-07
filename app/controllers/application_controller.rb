class ApplicationController < ActionController::Base
  include AuthorizationWithContext
  include CurrentCountryCode
  include CurrentCurrencyCode
  include FeatureFlag
  include ErrorHandling
  include Deeplink
  include SimpleCaptcha::ControllerHelpers
  include LogstashHandler
  include LogstashMetadata
  include DeviseExtension

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_error
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  force_ssl if: :ssl_enabled?
  before_action :log_http_user_agent
  before_action :set_locale
  before_action :set_seo_settings
  before_action :cn_redirect_to
  before_action :set_request_filter
  before_action :set_uuid_session_id
  after_action :store_location

  def version
    if request.headers['CMDP-DEBUG'] == 'commandp'
      render :json => { region: Region.region, environment: Rails.env, version: GIT_VERSION, unicorn_start_time_at: unicorn_process_start_time }
    else
      render_404
    end
  end

  def cn_redirect_to
    return unless come_from_china?
    return if non_redirect_china_site?
    redirect_to 'http://commandp.com.cn' if request.host == 'commandp.com'
    redirect_to 'http://staging.commandp.com.cn' if request.host == 'staging.commandp.com'
  end

  def default_url_options(_options = {})
    { locale: I18n.locale }
  end

  def after_sign_in_path_for(resource)
    case resource
    when User
      session[:return_to] || root_path
    when Admin
      resource.logcraft_user = current_admin
      resource.create_activity(:sign_in, ip: remote_ip,
                                         channel: 'web',
                                         os: user_agent.os,
                                         browser: user_agent.browser)
      admin_root_path
    when FactoryMember
      print_print_path
    when Store
      store_backend_store_path
    end
  end

  def after_sign_out_path_for(resource)
    case resource
    when :store
      new_store_session_path
    when :factory_member
      new_factory_member_session_path
    else
      root_path
    end
  end

  def store_location
    if !request.fullpath.match('/users') &&
       !request.xhr? # don't store ajax calls
      session[:return_to] = request.fullpath
    end
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user)
  end

  helper_method :permitted_params

  def render_404
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      format.json { render json: RecordNotFoundError.new.to_json, status: :not_found }
      format.xml { head :not_found }
      format.any { head :not_found }
    end
  end

  def log_with_current_user(model)
    if model.respond_to?(:create_activity)
      model.logcraft_user = current_user
      model.logcraft_source = { channel: 'web',
                                ip: remote_ip,
                                os_type: os_type,
                                os_version: user_agent.os || 'Unknown' }
    end
  end

  def os_type
    user_agent.platform || 'Unknown'
  end

  delegate :remote_ip, to: :request

  def user_agent
    @user_agent ||= UserAgent.parse(request.user_agent)
  end

  helper_method :user_agent

  def staff_available?
    return cookies[:staff_available] = true if params[:staff].to_b || cookies[:staff_available].to_b
    false
  end
  helper_method :staff_available?

  # 让各类型浏览器下载的文件名称不乱码
  def file_disposition(file_name, file_extension, with_date: true)
    file_name = with_date ? "#{file_name}_#{Time.zone.today}" : file_name
    file_name = CGI.escape("#{file_name}.#{file_extension}")
    if browser.ie?
      "attachment; filename=#{file_name}"
    else
      "attachment; filename*=utf-8''#{file_name}"
    end
  end

  def mark_csv_data(data)
    "\xEF\xBB\xBF#{data}"
  end

  helper_method :mark_csv_data

  private

  def log_http_user_agent
    $redis.hincrby("web:requests_#{Time.zone.today}", 'All', 1)
    $redis.hincrby("web:requests_#{Time.zone.today}", 'Bot', 1) if request.headers['HTTP_USER_AGENT'] =~ /bot|slurp/i
  end

  def set_locale
    if params[:locale].blank? && !request.fullpath.start_with?('/admin', '/print', '/account', '/webapi', '/health-check')
      redirect_to url_for(params.merge(locale: extract_locale_from_accept_language_header))
    else
      I18n.locale = normalize_locale(params[:locale])
    end
  end

  def extract_locale_from_accept_language_header
    http_accept_language.preferred_language_from(I18n.available_locales) || I18n.default_locale
  end

  def normalize_locale(locale)
    return extract_locale_from_accept_language_header if locale.nil?
    return locale if I18n.available_locales.include?(locale.to_sym)
    return 'zh-TW' if locale == 'zh'
    I18n.default_locale
  end

  def set_seo_settings
    set_meta_tags site: I18n.t('brand.name'),
                  title: I18n.t('about.title'),
                  description: I18n.t('about.description'),
                  alternate: href_lang,
                  publisher: 'https://plus.google.com/107493885872406432929',
                  og: {
                    title: I18n.t('brand.name'),
                    type: 'website',
                    site_name: I18n.t('site.name'),
                    url: request.original_url,
                    image: view_context.asset_url('fb_share_global.jpg'),
                    description: I18n.t('about.description')
                  }
  end

  def href_lang
    unless request.fullpath.start_with?('/emails')
      hash = {}
      I18n.available_locales.each do |locale|
        hash[locale.to_s] = root_url(locale: locale)
      end
      hash
    end
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Settings.Staging.username && password == Settings.Staging.password
    end
  end

  def set_device_type
    request.variant = browser.mobile? ? :phone : :web
  end

  def not_found_error
    error_handler(RecordNotFoundError.new)
  end

  def unicorn_process_start_time
    unicorn_pid_file = File.exist?('../../shared/pids/unicorn.pid.oldbin') ? 'unicorn.pid.oldbin' : 'unicorn.pid'
    unicorn_file = File.open("../../shared/pids/#{unicorn_pid_file}", "rb")
    unicorn_pid = unicorn_file.read.remove(/\n/)

    start_time = Time.parse(`ps -eo pid,lstart | grep #{unicorn_pid}`.remove(/\n/).remove("#{unicorn_pid} "))
  rescue => _e
    nil
  end

  def ssl_enabled?
    !(Rails.env.development? || Rails.env.test?) && !(request.path =~ /health-check/)
  end
end
