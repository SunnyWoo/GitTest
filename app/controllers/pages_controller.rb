class PagesController < ApplicationController
  before_action :set_device_type, only: %i(terms_of_service terms privacy)
  skip_before_action :verify_authenticity_token, only: %i(not_found)

  def robots
    robots = File.read(Rails.root + "config/robots/robots.#{Rails.env}.txt")
    render text: robots, layout: false, content_type: 'text/plain'
  end

  def home
    @works = HomeProducts.scope
    @links = HomeLink.limit(5)
    @app_url = deeplink('home')
    set_meta_tags title: I18n.t('home.title'),
                  description: I18n.t('home.description'),
                  og: {
                    title: I18n.t('home.title'),
                    description: I18n.t('home.description'),
                    type: 'website',
                    image: view_context.asset_url('fb_share_global.jpg'),
                    url: root_url(locale: params[:locale])
                  },
                  al: {
                    ios: {
                      url: @app_url,
                      app_store_id: 898_632_563,
                      app_name: I18n.t('app.name')
                    },
                    web: {
                      url: root_url,
                      should_fallback: 'true'
                    }
                  }
  end

  def about
    set_meta_tags title: I18n.t('about.title')
  end

  def support
    @zendesk_ticket = ZendeskForm.new
    set_meta_tags title: I18n.t('about.title')
  end

  def receive_support
    locale = params[:locale] ? params[:locale] : I18n.locale.to_s
    @zendesk_ticket = ZendeskForm.new(params[:zendesk_form].merge(locale: locale,
                                                                  user: current_user))
    res = @zendesk_ticket.save!
    if res[:status]
      redirect_to support_path, flash: { notice: t('home.sent-success') }
    else
      redirect_to support_path, flash: { error: res[:message] }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to support_path, flash: { error: @zendesk_ticket.errors.full_messages.join(', ') }
  end

  def career
    redirect_to careers_path, status: 301
  end

  def careers
    set_meta_tags title: I18n.t('career.title'),
                  site: nil,
                  description: I18n.t('career.description'),
                  og: {
                    title: I18n.t('career.title'),
                    description: I18n.t('career.description'),
                    image: view_context.asset_url('seo/web_seo_100_yl_careers.jpg')
                  }
  end

  def terms_of_service
    if Region.china?
      I18n.locale = 'zh-CN' if I18n.locale.to_s != 'zh-TW'
    else
      I18n.locale = 'zh-TW' if I18n.locale.to_s != 'zh-CN'
    end

    set_meta_tags title: t('terms_use.title'),
                  description: I18n.t('terms_use.description'),
                  og: {
                    title: "#{t('site.name')} | #{t('terms_use.title')}",
                    description: I18n.t('terms_use.description'),
                    image: view_context.asset_url('seo/web_seo_100_yl_home.jpg')
                  }
  end

  def terms
    I18n.locale = 'zh-CN' if I18n.locale.to_s != 'zh-TW'
    set_meta_tags title: t('terms_use.title'),
                  description: I18n.t('terms_use.description'),
                  og: {
                    title: "#{t('site.name')} | #{t('terms_use.title')}",
                    description: I18n.t('terms_use.description'),
                    image: view_context.asset_url('seo/web_seo_100_yl_home.jpg')
                  }
  end

  def privacy
    redirect_to terms_path
  end

  def not_found
    render file: 'public/404.html', status: :not_found
  end

  def proxy
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Methods'] = 'OPTIONS, GET'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Origin'] = root_url

    data = HTTParty.get(params[:url])
    mime_type = data.content_type
    encoded_data = Base64.encode64(data)
    data_uri = "data:#{mime_type};base64,#{encoded_data}"
    callback = params[:callback]
    render js: "#{callback}(#{data_uri.to_json})"
  end

  def health_check
    render text: 'Healthy!'
  end
end
