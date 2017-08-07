class MobileCouponSendWorker
  include Sidekiq::Worker
  # #TODO 之後可以拿掉 retry_sidekiq , 可以問 sammy or rich
  def perform(user_id, notice_id, retry_sidekiq = false)
    Mobile::SendCouponService.new(user_id, notice_id).execute
  end
end
