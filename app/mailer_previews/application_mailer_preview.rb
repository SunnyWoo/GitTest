class ApplicationMailerPreview
  def notice_admin
    emails = @emails || 'emails@mail.com'
    subject = @subject || 'subject'
    content = @content || "Here is some basic \n text... <br>...with a \r\n line break."
    ApplicationMailer.notice_admin emails, subject, content
  end
end
