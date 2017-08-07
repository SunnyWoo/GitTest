class DeliverOrder::DeliverService < DeliverOrder::BaseService
  attr_accessor :order

  def initialize(order)
    @order = order
    super()
  end

  def execute
    post('orders', query: order.china_archive_attributes)
    order_item_delivered
    order_delivered
    UpdateRemoteInfoWorker.perform_in(2.hours, order.id)
  end

  private

  def order_item_delivered
    order.need_deliver_order_items.each(&:deliver!)
  end

  def order_delivered
    order.delivered_at = Time.zone.now
    order.flags << :internal_transfer
    order.save
  end
end
