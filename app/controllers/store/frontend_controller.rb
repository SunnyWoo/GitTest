class Store::FrontendController < ApplicationController
  layout 'designer_store'
  before_action :meta_setting

  rescue_from StandardError, with: :render_server_error_page unless Rails.env.development?
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_page

  protected

  def current_user_or_guest
    current_user || User.new_guest.tap do |user|
      sign_in user
    end
  end

  def meta_setting(opt = {})
    title = opt.delete(:title) || I18n.t('store.seo.store_title', name: nil)
    desc = opt.delete(:desc) || I18n.t('store.seo.store_desc', name: nil)
    image = opt.delete(:image)
    set_meta_tags site: nil,
                  title: title,
                  description: desc,
                  alternate: nil,
                  publisher: nil,
                  og: {
                    title: title,
                    type: 'website',
                    site_name: title,
                    url: request.original_url,
                    image: image,
                    description: desc
                  }
  end

  private

  def render_not_found_page
    render file: 'public/designer_store/404.html', status: :not_found, layout: false
  end

  def render_server_error_page(e)
    Rollbar.error(e)
    render file: 'public/designer_store/500.html', status: :server_error, layout: false
  end
end
