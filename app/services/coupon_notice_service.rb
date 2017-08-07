class CouponNoticeService
  attr_reader :user_id

  def initialize(user_id)
    @user_id = user_id
  end

  def execute
    return execute_to_mobile if mobile_is_ready?
    execute_to_email if email_is_ready?
  end

  private

  def user
    User.find(user_id)
  end

  def execute_to_mobile
    return if user.send_fresh
    user.update send_fresh: true
    CouponNotice.china.mobile_available.each do |notice|
      MobileCouponSendWorker.perform_async(user_id, notice.id)
    end
  end

  def execute_to_email
    return if user.send_fresh
    user.update send_fresh: true
    EmailCouponSendWorker.perform_async(user_id)
  end

  def mobile_is_ready?
    user.mobile.present? && user.mobile.to_s.match(/^[0-9]+$/)
  end

  def email_is_ready?
    user.confirmed? && !user.email.match(User::GUEST_EMAIL_PATTERN)
  end
end
