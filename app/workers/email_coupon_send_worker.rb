class EmailCouponSendWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find user_id
    UserMailer.send_coupon(user).deliver
  end
end
