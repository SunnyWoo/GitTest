class PaymentRemindSender
  include Sidekiq::Worker

  def perform(order_id)
    @order = Order.find(order_id)
    @order.send_payment_remind
  end
end
