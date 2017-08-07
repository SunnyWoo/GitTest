class Webhook::MailController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :verify
  before_action :find_order

  class InvalidRequestError < ApplicationError; end

  private

  def verify
    begin
      verify_signature? or raise InvalidRequestError
    rescue InvalidRequestError
      render json: { message: "Invalid parameters" }, status: :bad_request
    end
  end

  def verify_signature?
    mail_response.signature == OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest::Digest.new('sha256'),
      Settings.SMTP.api_key,
      '%s%s' % [mail_response.timestamp, mail_response.token])
  end

  def mail_response
    @response ||= MailgunResponse.new(params)
  end

  def find_order
    begin
      @order = Order.find_by!(order_no: mail_response.order_no)
    rescue ActiveRecord::RecordNotFound
      render json: { message: "Order for #{mail_response.recipient} not found" }, status: :not_found
    end
  end
end
