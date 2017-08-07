class Payment::PaypalController < ApplicationController
  include FreeChecking

  before_action :find_cart, only: %w(begin callback)
  before_action :find_order, except: 'begin'

  def begin
    @order = if params[:order_no]
               Order.pending.find_by!(order_no: params[:order_no])
             else
               @cart.build_order
             end
    log_with_current_user @order
    @order.checked_out_at = Time.zone.now
    if @order.save
      free_checking(@order, @cart) or begin
        return_url = callback_payment_paypal_url(order_no: @order.order_no)
        cancel_url = cart_index_url
        Timeout.timeout Settings.payment_timeout.to_i do
          redirect_to @order.payment_object.webpay_url(return_url: return_url,
                                                       cancel_url: cancel_url)
        end
      rescue Timeout::Error
        message = I18n.t('errors.payment_time_out', payment: @order.payment_object.name)
        flash[:error] = message
        @order.create_activity(:pay_fail, message: message, payment_method: 'paypal')
        redirect_to order_result_path(@order.order_no)
      rescue PaymentPriceConflictError => e
        @order.create_activity(:pay_conflict, e.as_json[:detail].merge(message: e.message))
        WarningSender.perform_in(30.seconds, @order.id)
      end
    else
      render json: { status: 'error', message: @order.errors.full_messages },
             status: :bad_request
    end
  end

  def callback
    payment = PayPal::SDK::REST::Payment.find(@order.payment_id)
    payment.execute(payer_id: params['PayerID'])
    log_with_current_user @order
    @order.logcraft_extra_info = @order.payment_object.to_hash
    if payment.state == 'approved'
      @order.pay!
      @order.create_activity(:paid)
      @cart.clean(@order)
      redirect_to finish_payment_paypal_path(order_no: params[:order_no])
    else
      @order.create_activity(:pay_fail, message: payment.error.to_s, payment_method: 'paypal')
      redirect_to order_result_path(@order.order_no)
    end
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
    @order = Order.find_by!(payment: 'paypal', order_no: params[:order_no])
  end
end
