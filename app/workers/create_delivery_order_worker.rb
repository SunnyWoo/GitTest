class CreateDeliveryOrderWorker
  include Sidekiq::Worker
  sidekiq_options queue: :deliver_order

  sidekiq_retry_in do |count|
    10.minutes * (count + 1)
  end

  def perform(query)
    DeliverOrder::ReceiverService.new(query).create
  end
end
