class Webhook::BouncedMailsController < Webhook::MailController
  def create
    @order.create_activity(:email_deliver_failed,
                               recipient: mail_response.recipient,
                               subject: mail_response.subject,
                               event: mail_response.event,
                               error_messages: mail_response.bounced_message)
    render json: { message: 'Ok' }, status: :ok
  end
end
