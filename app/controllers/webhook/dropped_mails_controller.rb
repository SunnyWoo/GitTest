class Webhook::DroppedMailsController < Webhook:: MailController
  def create
    @order.create_activity(:email_deliver_failed,
                               recipient: mail_response.recipient,
                               subject: mail_response.subject,
                               event: mail_response.event,
                               error_messages: mail_response.dropped_message)
    render nothing: true
  end
end
