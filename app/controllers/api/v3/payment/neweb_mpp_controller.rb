class Api::V3::Payment::NewebMppController < ApiV3Controller
  include PaymentMethods


=begin
@api {get} /api/payment/neweb_mpp/begin Begin neweb mpp payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentNewebMpp
@apiName BeginPaymentNewebMpp
@apiParam {String} uuid Order uuid
@apiParam {String} order_no Order order_no
@apiParam {String} return_url url redirect_back to website after neweb mpp finish pay action
@apiSuccessExample {json} Success-Response:
  {
    "webpay_url" => "https://testmaple2.neweb.com.tw/NewebmPP/cdcard.
    jsp?amount=99&approveflag=1&checksum=d07f90fbc066bf959e1cf49ef99d84af&depositflag=1&englishmode=0&merchantnumber=760346&op=AcceptPayment&ordernumber=1511133400011US&orderurl=http%3A%2F%2Ftest.
    host%2Fwebhook%2Fneweb_mpp%2Fwriteoff%3Flocale%3Den&returnurl=http://commandp.dev/callback"
}
=end
  def begin
    fail OrderPayError, 'order is already paid or canceled' unless @order.pending?
    fail ApplicationError, 'return_url is missing' unless params[:return_url].present?
    check_url(params[:return_url])
    log_with_current_user @order
    if free_check(@order)
      render json: { paid: true, message: 'Trigger order#pay!' }
    else
      Timeout.timeout Settings.payment_timeout.to_i do
        webpay_url = @order.payment_object.webpay_url(return_url: params[:return_url],
                                                      order_url:  webhook_neweb_mpp_writeoff_url)
        @order.create_activity(:prepare_webpay_url, payment_method: 'neweb/mpp')
        render json: { webpay_url: webpay_url }
      end
    end
  rescue Timeout::Error
    message = I18n.t('errors.payment_time_out', payment: @order.payment_method)
    @order.create_activity(:pay_fail, message: message, payment_method: @order.payment_method)
    fail ApplicationError, message
  rescue => e
    fail ApplicationError, e.message
  end

=begin
@api {post} /api/payment/neweb_mpp/veirfy Verify Neweb Mpp payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentNewebMpp
@apiName VerifyPaymentNewebMpp
@apiParam {String} uuid Order uuid
@apiSuccessExample {json} Success-Response:
{
       "paid": true,
    "message": "The order is paid!"
}
=end
  # neweb/mpp付款成功是靠webhook回戳才知道的
  def verify
    fail ApplicationError unless @order.paid? || @order.may_pay?
    if @order.paid?
      render json: { paid: true, message: 'The order is paid!' }
    elsif @order.activities.find_by(key: 'prepare_webpay_url')
      render json: { paid: false, message: 'Please wating for neweb/mpp webhook' }, status: :bad_request
    else
      render json: { paid: false, message: 'The order did not make any begin request' }, status: :bad_request
    end
  end
end
