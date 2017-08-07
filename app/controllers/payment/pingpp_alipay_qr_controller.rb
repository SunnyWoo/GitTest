class Payment::PingppAlipayQrController < ApplicationController
  include FreeChecking
  include PingppMethods

  before_action :find_cart, only: %w(begin pay_result)
  before_action :find_order, except: 'begin'

  def begin
    @order = if params[:order_no]
               Order.pending.find_by!(order_no: params[:order_no])
             else
               @cart.build_order
             end
    log_with_current_user @order

    if @order.save!
      free_checking(@order, @cart) or begin
        qr_url = charge.credential['alipay_qr']
        @qrcode = RQRCode::QRCode.new(qr_url)
      end
    else
      render json: { status: 'error', message: @order.errors.full_messages },
             status: :bad_request
    end
  end

  def pay_result
    if @order.paid?
      @cart.clean(@order)
      render json: { paid: true }
    else
      render json: { paid: false }
    end
  end

  private

  def find_cart
    @cart = CartSession.new(controller: self, user_id: current_user.id)
  end

  def find_order
    @order = Order.find_by(payment: 'pingpp_alipay_qr', order_no: params[:order_no])
  end

  def charge
    @charge ||= Pingpp::Charge.create(pingpp_params(@order, 'alipay_qr'))
  end
end
