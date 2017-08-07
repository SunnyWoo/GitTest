class ReceiptWithStatusSender
  include Sidekiq::Worker

  def perform(order_id)
    @order = Order.find(order_id)
    return if @order.shop?
    @order.logcraft_source = { channel: 'worker' }
    @order.logcraft_extra_info = { email: @order.billing_info.email }
    @order.send_receipt_with_status
  end
end
