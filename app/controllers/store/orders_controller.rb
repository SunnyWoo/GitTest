class Store::OrdersController < Store::FrontendController
  before_action :check_order_no_and_phone, :find_order, only: :search_result
  def search_result
    render_search_fail unless @order.present? && @order.billing_info_phone == @phone
    @order = Api::V3::OrderDecorator.new(@order) if @order.present?
  end

  def search
    # @store = Store.find(params[:store_id])
    meta_setting(title: I18n.t('store.seo.order_search_title'),
                 desc: I18n.t('store.seo.order_search_desc'))
  end

  private

  def find_order
    @order = Order.viewable.shop.find_by(order_no: @order_no)
  end

  def check_order_no_and_phone
    @phone = params[:order].try(:[], :billing_info_phone)
    @order_no = params[:order].try(:[], :order_no)
  end

  def render_search_fail
    fail RecordNotFoundError, I18n.t('store.error.order_not_found')
  end
end
