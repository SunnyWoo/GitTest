class Promotion::OrderUnlockedEventWorker
  include Sidekiq::Worker

  def perform(promotion_id, order_id, event)
    promotion = Promotion.find promotion_id
    order = Order.find order_id
    return if order.locked?
    promotion.strategy.send(event, order)
  end
end
