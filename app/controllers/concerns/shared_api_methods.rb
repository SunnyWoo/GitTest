module SharedApiMethods
  extend ActiveSupport::Concern

  def log_http_user_agent
    logger.info( request.headers["HTTP_USER_AGENT"] )
    $redis.hincrby("public_api:requests_#{Time.zone.today}", "All", 1)
    $redis.hincrby("public_api:app_type_#{Time.zone.today}", os_type, 1)
    $redis.hincrby("public_api:app_version_#{Time.zone.today}", app_version, 1)
    $redis.hincrby("public_api:app_model_#{Time.zone.today}", device_model, 1)
  end

  def log_request
    logger.debug "Request => #{params}"
    logger.debug "Headers => #{request.headers.map{ |k, v| "#{k}:#{v}" if k =~ /HTTP/ }.uniq.join(', ')}"
  end

  def who
    render json: {
      'app_version'  => app_version,
      'app_type'     => os_type,
      'os_type'      => os_type,
      'os_version'   => os_version,
      'app_model'    => device_model,
      'device_model' => device_model
    }
  end

  def rn_version
    # 在兩個 Client 端都改好後會移除
    case params[:platform]
    when 'android'
      rn_android_version
    else
      rn_ios_version
    end
  end

  def rn_ios_version
    render json: SiteSetting.rn_ios_meta
    fresh_when(etag: SiteSetting.rn_ios_meta)
  end

  def rn_android_version
    render json: SiteSetting.rn_android_meta
    fresh_when(etag: SiteSetting.rn_android_meta)
  end

  def current_user
    @current_user
  end

  def set_locale
    I18n.locale = extract_locale_from_accept_language_header
  end

  def this
    self
  end

  def api_permitted_params
    @api_permitted_params ||= ApiPermittedParams.new(params, current_user)
  end
end
