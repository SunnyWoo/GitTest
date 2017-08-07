class Store::ProductsController < Store::FrontendController
  before_action :find_store, only: [:show]
  before_action :find_work, only: [:show]
  before_action :find_cart, only: [:show]

  def show
    gon.push store_id: @store.id, work_uuid: @work.uuid
    meta_setting(title: I18n.t('store.seo.preview_title', name: @work.name),
                 desc: I18n.t('store.seo.preview_desc'))
    fresh_when(etag: @work, last_modified: @work.updated_at)
  end

  private

  def find_store
    @store = Store.find(params[:store_id])
  end

  def find_work
    current_work = @store.standardized_works.published.find(params[:id])
    @work = Store::WorkDecorator.new(current_work)
  end

  def find_cart
    @cart = CartSession.new(controller: self, store_id: @store.id, user_id: current_user_or_guest.id)
  end
end
