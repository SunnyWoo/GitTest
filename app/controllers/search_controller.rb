class SearchController < ApplicationController
  include SearchSupport
  before_action :search_work, only: :index

  def index
    @query = params[:query]
    set_meta_tags title: t('search.title', search: @query),
                  description: t('search.description', search: @query),
                  og: {
                    title: t("search.title", search: @query),
                    description: t('search.description', search: @query),
                    image: view_context.asset_url('seo/web_seo_100_yl_others.jpg')
                  }
    respond_to do |format|
      format.html
      format.js
    end
  end
end
