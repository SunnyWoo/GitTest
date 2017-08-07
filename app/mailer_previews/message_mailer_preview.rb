class MessageMailerPreview
  def resend
    message = Message.find_by(id: @id) || Message.first
    MessageMailer.resend message
  end
end
