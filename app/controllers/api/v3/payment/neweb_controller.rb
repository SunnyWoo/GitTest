class Api::V3::Payment::NewebController < ApiV3Controller
  include PaymentMethods

  # 僅讓neweb/atm, neweb/mmk各表
  def begin
    fail OrderPayError, 'order is not pending' unless @order.pending?
    log_with_current_user @order
    if free_check(@order)
      render json: { paid: true, message: 'Trigger order#pay!' }
    else
      payment_object = @order.payment_object
      Timeout.timeout Settings.payment_timeout.to_i do
        if payment_object.pay
          render json: @order.payment_object.to_hash
        else
          render json: { paid: false, error: payment_object.error }, status: :bad_request
        end
      end
    end
  rescue Timeout::Error
    message = I18n.t('errors.payment_time_out', payment: @order.payment_method)
    @order.create_activity(:pay_fail, message: message, payment_method: @order.payment_method)
    fail ApplicationError, message
  end
end
