class ShopsController < ApplicationController
  include WorksSorter
  before_action :find_product_category_or_product_model, only: :show

  def index
    @model = ProductModel.sellable_on('website').order_by('website').default
    category_and_sort
    prepare_models_and_works
  end

  # moved_permanently
  def show
    category_and_sort
    prepare_models_and_works
    render :index
  end

  private

  def prepare_models_and_works
    @models = ProductModel.sellable_on('website').order_by('website').model_list(@category.key)
    @works = sorted_works(@sort, @category.work_list(@model)).page([params[:page].to_i, 1].max).per_page(45)
    @title = @model.friendly_name
    @app_url = @model.name == 'All' ? deeplink('shop') : deeplink("shop?model=#{@model.key}")
    set_meta_tags title: [t('shop.title'), @model.name],
                  description: I18n.t('shop.description'),
                  og: {
                    title: "#{t('site.name')} | #{t('shop.title')} | #{@model.name}",
                    description: I18n.t('shop.description'),
                    image: view_context.asset_url('seo/web_seo_100_yl_others.jpg')
                  },
                  al: {
                    ios: {
                      url: @app_url,
                      app_store_id: 898_632_563,
                      app_name: I18n.t('app.name')
                    },
                    web: {
                      url: shop_url(@model.slug),
                      should_fallback: 'true'
                    }
                  }
  end

  def category_and_sort
    if @model.is_a?(ProductModel)
      @sort = params[:sort] || 'New'
      @category = @model.category
    else
      @sort = params[:sort] || 'Random'
      @category = ProductCategory.find_or_initialize_by(key: params[:category])
    end
    @categories = ProductCategory.category_list
  end

  def find_product_category_or_product_model
    if ProductCategory.find_by(key: params[:id])
      @model = ProductModel.sellable_on('website').order_by('website').default
      params[:category] = params[:id]
    else
      @model = ProductModel.sellable_on('website').wildcard_or_find_by(params[:id])
    end
  end
end
