class WarningSender
  include Sidekiq::Worker

  def perform(order_id)
    @order = Order.find order_id
    @order.logcraft_source = { channel: 'worker' }
    @order.send_warning
  end
end
