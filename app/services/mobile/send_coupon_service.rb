class Mobile::SendCouponService
  COMPANY = '噗印商城'
  attr_reader :user, :notice_id

  def initialize(user_id, notice_id)
    @user = User.find(user_id)
    @notice_id = notice_id
    @text = render_text
  end

  def execute
    ChinaSMS.use :emay, username: Settings.emay.marketing.cdkey, password: Settings.emay.marketing.password
    result = ChinaSMS.to user.mobile, @text
    if result[:code] != '0'
      message = "Send SMS Failed [emay-error-code:#{result[:code]}]"
      user.create_activity(:mobile_send_coupon_code_fail, mobile:  user.mobile,
                                                          message: message)
      fail ApplicationError, message
    else
      user.create_activity(:mobile_send_coupon_code, coupon_title: coupon_notice.coupon.title,
                                                     code:         coupon_notice.coupon_code,
                                                     mobile:       user.mobile)
      result
    end
  end

  protected

  def coupon_notice
    @coupon_notice ||= CouponNotice.find(notice_id)
  end

  def render_text
    message = coupon_notice.render_notice
    "【#{COMPANY}】亲爱的用户，#{message}回复TD退订" # 亿美短信格式：【签名】+ 内容 + 回复TD退订
  end
end
