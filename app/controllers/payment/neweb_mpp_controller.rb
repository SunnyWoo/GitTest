class Payment::NewebMppController < ApplicationController
  include FreeChecking

  before_action :find_cart, only: %w'begin callback'
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
        order_url = webhook_neweb_mpp_writeoff_url
        return_url = callback_payment_neweb_mpp_url(order_no: @order.order_no)
        Timeout.timeout Settings.payment_timeout.to_i do
          redirect_to @order.payment_object.webpay_url(order_url: order_url,
                                                       return_url: return_url)
        end
      rescue Timeout::Error
        message = I18n.t('errors.payment_time_out', payment: @order.payment_object.name)
        flash[:error] = message
        @order.create_activity(:pay_fail, message: message, payment_method: 'neweb_mpp')
        redirect_to order_result_path(@order.order_no)
      end
    else
      render json: { status: 'error', message: @order.errors.full_messages },
             status: :bad_request
    end
  end

  skip_before_action :verify_authenticity_token, only: :callback
  def callback
    @order.present? ? @cart.clean(@order) : @cart.clean
    redirect_to finish_payment_neweb_mpp_url(order_no: params[:order_no])
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
    @order = Order.find_by!(payment: 'neweb_mpp', order_no: params[:order_no])
  end
end
