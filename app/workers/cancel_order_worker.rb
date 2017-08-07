class CancelOrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    if order.pending?
      order.cancel!
      order.create_activity(:cancel_order, message: '自動取消 Order', worker: 'CancelOrderWorker')
    end
  end
end
