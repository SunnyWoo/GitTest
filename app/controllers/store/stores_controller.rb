class Store::StoresController < Store::FrontendController
  before_action :find_store, only: :show
  before_action :find_something, only: :show

  def index
    render layout: 'designer_store2'
  end

  def show
    image = @store.kv.first.present? ? @store.kv.first.image.url : nil
    meta_setting(title: I18n.t('store.seo.store_title', name: @store.name),
                 desc: I18n.t('store.seo.store_desc', name: @store.name),
                 image: image)
  end

  def support
    meta_setting(title: I18n.t('store.seo.contact_us_title'),
                 desc: I18n.t('store.seo.contact_us_desc'))
  end

  private

  def find_store
    @store = Store.find(params[:id])
  end

  def find_something
    @standardized_works = @store.standardized_works.published.includes(:price_tier, product: [:price_tier, :currencies, :translations], category: [:translations]).recent
    @categories = ProductCategory.by_workables(@standardized_works)
    @products = ProductModel.by_workables(@standardized_works)

    @templates = @store.templates.published.recent
    @templates_categories = ProductCategory.by_product_templates(@templates)
    @templates_products = ProductModel.by_product_templates(@templates)
  end
end
