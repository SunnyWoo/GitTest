class PaymentDun
  include Sidekiq::Worker

  def perform(order_id)
    PaymentDunService.new(order_id, SmsService.new(provider: :sms_get)).execute
  end
end
