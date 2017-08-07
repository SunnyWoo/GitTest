class DeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views
  default from: MailerService.from
  default reply_to: MailerService.from
  layout 'order_mail'
  before_filter :find_email_banner

  def confirmation_instructions(record, token, opts={})
    locale = record.locale || 'en'
    I18n.with_locale(locale) do
      opts[:subject] = I18n.t('devise.mailer.confirmation_instructions.subject', sitename: I18n.t('site.name'))
      opts[:reply_to] = nil
      super
    end
  end

  def reset_password_instructions(record, token, opts={})
    locale = record.locale || 'en'
    I18n.with_locale(locale) do
      opts[:subject] = I18n.t('devise.mailer.reset_password_instructions.subject', sitename: I18n.t('site.name'))
      @token = token
      super
    end
  end

  private

  def find_email_banner
    @banner = EmailBanner.available.present? ? EmailBanner.available.file.s600.url : nil
  end
end
