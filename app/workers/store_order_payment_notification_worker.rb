class StoreOrderPaymentNotificationWorker
  include Sidekiq::Worker

  def perform(order_id)
    StoreOrderPaymentNotificationService.new(order_id).execute
  end
end
