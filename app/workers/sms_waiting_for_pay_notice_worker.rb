class SmsWaitingForPayNoticeWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2


  def perform(order_id)
    Sms::WaitingForPayNoticeService.new(order_id).execute
  end
end
