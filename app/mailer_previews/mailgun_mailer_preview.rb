class MailgunMailerPreview
  def send_message
    id = @id || Newsletter.first.id
    MailgunMailer.send_message id
  end
end
