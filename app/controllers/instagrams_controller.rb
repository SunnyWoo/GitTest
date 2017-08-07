class InstagramsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :set_locale

  def show
    response.headers["Access-Control-Allow-Origin"] = "*"
    data = fetch_instagram_data
    if data.present?
      render json: { success: true, urls: data }, status: :ok
    else
      render json: { success: false }, status: :not_found
    end
  end

  protected

  def fetch_instagram_data
    im = InstagramMedia.new(hashtag: params.fetch(:hashtag, 'HelloIAm'))
    urls = im.get
    return false unless urls.present?
    urls
  end
end
