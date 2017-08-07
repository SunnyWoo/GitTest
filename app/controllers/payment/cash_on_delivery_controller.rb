class Payment::CashOnDeliveryController < ApplicationController
  include FreeChecking

  before_action :build_order, only: 'begin'
  before_action :find_order, except: 'begin'

  def begin
    log_with_current_user @order
    if @order.save
      free_checking(@order, @cart) or begin
        @order.pay!
        @cart.clean(@order)
        redirect_to finish_payment_cash_on_delivery_path(order_no: @order.order_no)
      end
    else
      render json: { status: 'error', message: @order.errors.full_messages },
             status: :bad_request
    end
  end

  def finish
    redirect_to order_result_path(@order.order_no)
  end

  private

  def build_order
    @cart = CartSession.new(controller: self, user_id: current_user.id)
    @order = if params[:order_no]
               Order.pending.find_by!(order_no: params[:order_no])
             else
               @cart.build_order
             end
  end

  def find_order
    @order = Order.find_by!(payment: 'cash_on_delivery', order_no: params[:order_no])
  end
end
