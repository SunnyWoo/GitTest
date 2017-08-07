class ApplicationMailer < ActionMailer::Base
  default from: MailerService.from
  layout 'mail'

  def notice_admin(emails, subject, content)
    @content = content
    mail to: emails, subject:subject
  end
end
