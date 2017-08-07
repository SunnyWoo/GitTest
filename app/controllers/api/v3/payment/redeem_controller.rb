class Api::V3::Payment::RedeemController < ApiV3Controller
  include PaymentMethods

=begin
@api {get} /api/payment/redeem/begin Begin redeem payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Payment
@apiName Begin Payment Redeem
@apiParam {String} uuid Order uuid
@apiParam {String} order_no Order order_no
@apiSuccessExample {json} Success-Response:
  {
    "status": "true", "order_no": "1610045400178TW"
  }
@apiErrorExample {json} Error-Response:
  {
    "status": "false", "error": "Order 無法被兌換"
  }
=end
  def begin
    fail OrderPayError, 'order is not pending' unless @order.pending?
    log_with_current_user @order
    if @order.payment_object.pay
      render json: { status: true, order_no: @order.order_no }
    else
      render json: { status: false, error: @order.errors.full_messages.join(',') }, status: :bad_request
    end
  end
end
