# 僅支援neweb/atm與neweb/mmk
class Payment::NewebController < ApplicationController
  include FreeChecking

  before_action :find_cart, only: 'begin'
  before_action :find_order, except: 'begin'

  def begin(payment_method)
    build_order
    @order.checked_out_at = Time.zone.now
    if @order.save
      free_checking(@order, @cart) or begin
        if @order.payment_object.pay
          @cart.clean(@order)
          Timeout.timeout Settings.payment_timeout.to_i do
            redirect_to_finish_url(payment_method)
          end
        else
          redirect_to_result_with_error(@order.payment_object.error)
        end
      rescue Timeout::Error
        message = I18n.t('errors.payment_time_out', payment: @order.payment_object.name)
        redirect_to_result_with_error(message)
      end
    else
      render json: { status: 'error', message: @order.errors.full_messages },
             status: :bad_request
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

  def find_order(payment_method)
    @order = Order.find_by!(payment: "neweb/#{payment_method}", order_no: params[:order_no])
  end

  def build_order
    @order = if params[:order_no]
               Order.pending.find_by!(order_no: params[:order_no])
             else
               @cart.build_order
             end
    log_with_current_user @order
  end

  def redirect_to_result_with_error(message)
    flash[:error] = message
    @order.create_activity(:pay_fail, message: message, payment_method: @order.payment_method)
    redirect_to order_result_path(@order.order_no)
  end

  def redirect_to_finish_url(payment_method)
    case payment_method
    when 'mmk' then redirect_to finish_payment_neweb_mmk_url(order_no: @order.order_no)
    when 'atm' then redirect_to finish_payment_neweb_atm_url(order_no: @order.order_no)
    end
  end
end
