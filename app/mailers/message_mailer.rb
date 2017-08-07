class MessageMailer < ApplicationMailer
  layout false

  def resend(message)
    @message = message
    headers["X-Mailgun-Variables"] = { 'order_no' => @message.order_no }.to_json
    mail to: @message.mail_to.split(', '),
         subject: @message.title
  end
end
