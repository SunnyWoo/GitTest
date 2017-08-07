class GuanyiPurchaseForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :note, :warehouse_code, :supplier_code, :order_type,
                :details, :service

  def initialize(order)
    @note = order.order_no

    @warehouse_code = 'factory-sh'
    @supplier_code = 'commandp_factory'
    @order_type = 'generate'

    @details = purchase_details(order)
    @service = GuanyiService.new
  end

  def attributes
    {
      warehouse_code: @warehouse_code,
      supplier_code: @supplier_code,
      order_type: @order_type,
      note: @note,

      detail_list: @details
    }
  end

  def post!
    @service.request('gy.erp.purchase.arrive.add', attributes) if valid?
  end

  private

  def purchase_price(item)
    Purchase::ProductReference.find_by(product_id: item.itemable.model_id).purchase_price
  end

  def purchase_details(order)
    order.order_items.map do |item|
      price = BigDecimal.new(purchase_price(item))
      {
        qty: item.quantity.to_s,
        price: price.to_s,
        item_code: item.itemable.product_code
      }
    end
  end
end
