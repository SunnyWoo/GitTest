class MailgunMailer < ApplicationMailer
  layout 'mailgun_mail'

  def send_message(id, locale: 'zh-TW')
    @newsletter = Newsletter.find(id)
    I18n.with_locale(locale) do
      email = mail to: @newsletter.filter_mail_to, subject: @newsletter.subject
      if delivery_method == :mailgun && @newsletter.mailgun_campaign
        email.mailgun_options = { campaign: @newsletter.mailgun_campaign.campaign_id }
      end
    end
  end
end
