class Webhook::DeliveredMailsController < Webhook::MailController
  def create
    @order.create_activity(:email_delivered,
                               recipient: mail_response.recipient,
                               subject: mail_response.subject)
    render nothing: true
  end
end
