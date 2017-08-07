class Payment::NewebAlipayController < ApplicationController
  include FreeChecking

  before_action :find_cart, only: %w'begin callback'
  before_action :find_order, only: 'finish'

  def begin
    @order = if params[:order_no]
               Order.pending.find_by!(order_no: params[:order_no])
             else
               @cart.build_order
             end
    log_with_current_user @order

    if @order.save
      free_checking(@order, @cart) or begin
        next_url = callback_payment_neweb_alipay_url
        @alipay_url = @order.payment_object.webpay_url(next_url: next_url)
      end
    else
      render json: { status: 'error', message: @order.errors.full_messages },
             status: :bad_request
    end
  end

  skip_before_action :verify_authenticity_token, only: :callback
  def callback
    order = Order.where(order_no: params[:ordernumber]).first
    order.present? ? @cart.clean(order) : @cart.clean
    redirect_to finish_payment_neweb_alipay_url(order_no: params[:ordernumber])
  end

  def finish
    redirect_to order_result_path(@order.order_no)
  end

  rescue_from Payment::Error do |e|
    render text: e.message
  end

  private

  def find_cart
    @cart = CartSession.new(controller: self, user_id: current_user.id)
  end

  def find_order
    @order = Order.find_by!(payment: 'neweb/alipay', order_no: params[:order_no])
  end
end
