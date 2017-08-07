class Webhook::PingppController < ApplicationController
  skip_before_action :set_locale, :authenticate
  skip_before_action :verify_authenticity_token

  before_action :set_format_json
  before_action :check_valid_event
  before_action :verify_signature

  def callback
    event_type = event['type']
    @event_object = event['data']['object']
    if event_type == 'charge.succeeded'
      charge_success_callback
    elsif event_type == 'refund.succeeded' && @event_object['status'] == 'succeeded'
      refund_success_callback
    end
    render json: { message: 'success' }
  end

  protected

  def set_format_json
    request.format = :json
  end

  def verify_signature
    signature = request.headers['x-pingplusplus-signature'].to_s
    pub_key_path = "#{Rails.root}/vendor/pingpp_rsa_public_key.pem"
    rsa_public_key = OpenSSL::PKey.read(File.read(pub_key_path))
    verified = rsa_public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(signature), request.raw_post)
    fail AuthenticationFailedError unless verified
  end

  def event
    @event ||= JSON.parse(request.raw_post)
  end

  def check_valid_event
    msg = 'Only support charge.succeeded and refund.succeeded type event object'
    fail ApplicationError, msg unless event['type'].in? ['charge.succeeded', 'refund.succeeded']
  end

  def charge_success_callback
    @order = Order.pending.find_by!(order_no: @event_object['order_no'])
    @order.payment_id = @event_object['id']
    @order.pay!
    @order.create_activity(:paid)
  end

  def refund_success_callback
    charge = Pingpp::Charge.retrieve(@event_object['charge'])
    @order = Order.find_by!(order_no: charge.order_no)
    PingppService.refund_success(@order,
                                 @event_object['id'],
                                 @event_object['amount'].to_f / 100,
                                 @event_object['description'])
  end
end
