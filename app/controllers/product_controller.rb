class ProductController < ApplicationController

  before_action :force_zh_tw
  before_action :find_product

  def info
    @categoryKey = params[:categoryKey]
    set_meta_tags title: @product[:meta_title],
                  description: @product[:meta_description],
                  keyword: @product[:meta_keyword],
                  og: {
                    title: @product[:meta_title],
                    description: @product[:meta_description],
                    keyword: @product[:meta_keyword],
                    image: get_og_image(@product[:meta_image_url])
                  }
    request.variant = :phone
    render "product/info", layout: 'campaign_v2',
            locals: {controller_name: 'campaign', action_name: 'show productintro_page'}
  end

  private

  def find_product
    @product = ProductIntroPage.find!(params[:categoryKey] || params[:id])
  end

  def force_zh_tw
    return if params[:locale] == 'zh-TW'
    redirect_to url_for(params.merge(locale: 'zh-TW'))
  end

  def get_og_image(asset_path)
    "#{ProductIntroPage.find_by('host')}/#{asset_path}"
  end

end
