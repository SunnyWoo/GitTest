class NuandaoOrderShippingWorker
  include Sidekiq::Worker

  def perform(order_id)
    NuandaoWebhookService::OrderShipping.new(order_id).execute
  end
end
