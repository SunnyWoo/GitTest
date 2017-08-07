class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  layout 'order_mail'
  before_filter :find_email_banner

  def send_password_reset(user_id, token, url)
    @user = User.find user_id
    @token = token
    @url = url
    locale = @user.locale || 'en'
    I18n.with_locale(locale) do
      mail to: @user.email,
           subject: I18n.t('devise.mailer.reset_password_instructions.subject', sitename: I18n.t('site.name'))
    end
  end

  def send_confirmation(user_id, token, url)
    @user = User.find user_id
    @token = token
    @url = url
    locale = @user.locale || 'en'
    I18n.with_locale(locale) do
      mail to: @user.email,
           subject: I18n.t('devise.mailer.confirmation_instructions.subject', sitename: I18n.t('site.name'))
    end
  end

  def send_welcome(user_id)
    @user = User.find user_id
    return if @user.email.match(User::GUEST_EMAIL_PATTERN)
    locale = @user.locale || 'en'
    I18n.with_locale(locale) do
      mail to: @user.email,
           subject: I18n.t('email.user.send_welcome.subject', sitename: I18n.t('site.name'))
    end
  end

  def send_coupon(user)
    return if email_coupon_notice.empty?
    @sender_notices = []
    email_coupon_notice.each do |notice|
      @sender_notices << notice.render_notice
      user.create_activity(:mobile_send_coupon_code,
                           coupon_title: notice.coupon.title,
                           code: notice.coupon_code,
                           email: user.email)
    end
    locale = user.locale || 'en'
    I18n.with_locale(locale) do
      mail to: user.email,
           subject: I18n.t('email.user.send_coupon.subject', sitename: I18n.t('site.name'))
    end
  end

  private

  def find_email_banner
    @banner = EmailBanner.available.present? ? EmailBanner.available.file.s600.url : nil
  end

  def email_coupon_notice
    CouponNotice.china.email_available
  end
end
