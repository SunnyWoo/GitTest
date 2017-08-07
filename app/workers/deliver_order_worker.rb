class DeliverOrderWorker
  include Sidekiq::Worker
  sidekiq_options queue: :deliver_order

  sidekiq_retry_in do |count|
    10.minutes * (count + 1)
  end

  def perform(order_id)
    order = Order.find(order_id)
    DeliverOrder::DeliverService.new(order).execute
  end
end
