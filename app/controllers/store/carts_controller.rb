class Store::CartsController < Store::FrontendController
  before_action :find_store
  before_action :find_cart

  def show
    redirect_to "#{SiteSetting.by_key('mobile_store_cart_url')}?store_id=#{@store.id}"
  end

  def add
    @work = StandardizedWork.with_available_product.find_by(uuid: params[:id]) ||
            Work.with_available_product.find_by(uuid: params[:id])
    if @work.is_a? Work
      @work.finish! unless @work.finished
    end
    @cart.add_items(@work.to_gid, params[:quantity] || 1)
    @cart.save
    render json: {
      status: :success,
      cart: @cart.items.as_json,
      meta: { items_count: @cart.items.count, total_quantity: @cart.item_sum }
    }
  end

  protected

  def find_store
    @store = Store.find(params[:store_id])
  end

  def find_cart
    @cart = CartSession.new(controller: self, store_id: @store.id, user_id: current_user_or_guest.id)
  end
end
