class Api::V3::Payment::PaypalController < ApiV3Controller
  include PaymentMethods

=begin
@api {get} /api/payment/paypal/begin Begin paypal payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentPaypal
@apiName BeginPaymentPaypal
@apiParam {String} uuid Order uuid
@apiParam {String} order_no Order order_no
@apiParam {String} return_url url redirect_back to website after paypal finish pay action
@apiParam {String} cancel_url url redirect_back to website when paypal fail to pay
@apiSuccessExample {json} Success-Response:
  {
    "webpay_url": "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-8JS71733BB065194H"
  }
=end
  def begin
    fail OrderPayError, 'order is already paid or canceled' unless @order.pending?
    check_url(params[:return_url], params[:cancel_url])
    log_with_current_user @order
    if free_check(@order)
      render json: { paid: true, message: 'Trigger order#pay!' }
    else
      Timeout.timeout Settings.payment_timeout.to_i do
        webpay_url = @order.payment_object.webpay_url(return_url: params[:return_url],
                                                      cancel_url: params[:cancel_url])
        render json: { webpay_url: webpay_url }
      end
    end
  rescue Timeout::Error
    message = I18n.t('errors.payment_time_out', payment: 'paypal')
    @order.create_activity(:pay_fail, message: message, payment_method: 'paypal')
    fail ApplicationError, message
  rescue PaymentPriceConflictError => e
    @order.create_activity(:pay_conflict, e.as_json[:detail].merge(message: e.message))
    WarningSender.perform_in(30.seconds, @order.id)
    fail PaymentPriceConflictError
  rescue => e
    fail ApplicationError, e.message
  end


=begin
@api {post} /api/payment/paypal/verify Verify Paypal payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentPaypal
@apiName VerifyPaymentPaypal
@apiParam {String} payer_id
@apiParam {String} order_no Order's order_no
@apiParam {String} uuid Order's uuid
@apiSuccessExample {json} Success-Response:
  {
    paid: 'true', message: 'Trigger order#pay!'
  }
=end

  def verify
    fail ApplicationError unless @order.paid? || @order.may_pay?
    if @order.paid?
      render json: { paid: true, message: 'The order is already paid' }
    else
      payment = find_payment
      payment.execute(payer_id: params['payer_id'])
      log_with_current_user @order
      @order.logcraft_extra_info = @order.payment_object.to_hash
      if payment.state == 'approved'
        @order.pay!
        @order.create_activity(:paid)
        render json: { paid: true, message: 'Trigger order#pay!' }
      else
        @order.create_activity(:pay_fail, message: payment.error.to_s, payment_method: 'paypal')
        render json: { paid: false, message: 'Paypal is not paid yet' }, status: :bad_request
      end
    end
  rescue PayPal::SDK::Core::Exceptions::ResourceNotFound
    fail ActiveRecord::RecordNotFound
  rescue => e
    fail ApplicationError, e.message
  end

=begin
@api {get} /api/payment/paypal/retrieve Retrieve Paypal payment object
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentPaypal
@apiName RetrievePaymentPaypal
@apiParam {String} order_no Order's order_no
@apiParam {String} uuid Order's uuid
@apiSuccessExample {json} Success-Response:
  {
  "id": "PAY-7MT225751J754281DKZCHOXY",
  "create_time": "2015-11-12T11:26:23.000+00:00",
  "update_time": "2015-11-12T11:26:23.000+00:00",
  "intent": "sale",
  "transactions": [
    {
      "amount": {
        "currency": "TWD",
        "total": "2998.00"
      },
      "payee": {
        "email": "david.commandp-facilitator@gmail.com"
      }
    }
  ],
  "state": "created",
  "redirect_urls": {
    "return_url": "http://commandp.dev/zh-TW/auth/jedi/callback?paymentId=PAY-7MT225751J754281DKZCHOXY",
    "cancel_url": "http://commandp.dev/zh-TW/auth/jedi/callback"
  },
  "links": [
    {
      "href": "https://api.sandbox.paypal.com/v1/payments/payment/PAY-7MT225751J754281DKZCHOXY",
      "rel": "self",
      "method": "GET"
    },
    {
      "href": "https://api.sandbox.paypal.com/v1/payments/payment/PAY-7MT225751J754281DKZCHOXY/execute",
      "rel": "execute",
      "method": "POST"
    },
    {
      "href": "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-8JS71733BB065194H",
      "rel": "approval_url",
      "method": "REDIRECT"
    }
  ]
}
=end

  def retrieve
    fail ApplicationError unless @order.paid? || @order.may_pay?
    render json: find_payment
  rescue PayPal::SDK::Core::Exceptions::ResourceNotFound
    fail ActiveRecord::RecordNotFound
  end

  protected

  def find_payment
    PayPal::SDK::REST::Payment.find(@order.payment_id)
  end
end
