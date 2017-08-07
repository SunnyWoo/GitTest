class DeliverOrder::OrderItemService < DeliverOrder::BaseService
  attr_accessor :order_item_id

  def initialize(order_item_id)
    @order_item_id = order_item_id
    super()
  end

  def execute
    get("order_items/#{order_item_id}")
  end
end
