class Payment::StripeController < ApplicationController
  include FreeChecking
  before_action :set_device_type
  before_action :find_cart
  before_action :find_order, only: [:callback, :finish]

  def begin
    @order = if params[:order_no]
               Order.pending.find_by!(order_no: params[:order_no])
             else
               @cart.build_order
             end
    @order.checked_out_at = Time.zone.now
    log_with_current_user @order
    if @order.save!
      free_checking(@order, @cart) or begin
        @url = callback_payment_stripe_path(order_no: @order.order_no)
      end
    else
      render json: { status: 'error', message: @order.errors.full_messages }, status: :bad_request
    end
  end

  def callback
    stripe_token = params[:order][:stripe_card_token]
    log_with_current_user @order
    if Stripe::ChargeService.new(@order, stripe_token).execute
      @cart.clean(@order)
      redirect_to finish_payment_stripe_path(order_no: @order.order_no)
    else
      redirect_to order_result_path(@order.order_no, error_message: @order.activities.where(key: :pay_fail).ordered.first.message)
    end
  end

  def finish
    redirect_to order_result_path(@order.order_no)
  end

  private

  def find_cart
    @cart = CartSession.new(controller: self, user_id: current_user.id)
  end

  def find_order
    @order = Order.find_by!(payment: 'stripe', order_no: params[:order_no])
  end
end
