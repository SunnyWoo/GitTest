class Api::V3::Payment::StripeController < ApiV3Controller
  include PaymentMethods

=begin
@api {get} /api/payment/stripe/begin Begin stripe payment,which just returns webpay_url exlucsive of payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentStripe
@apiName BeginPaymentStripe
@apiParam {String} uuid Order uuid
@apiParam {String} order_no Order order_no
@apiSuccessExample {json} Success-Response:
  {
    "webpay_url": "http://test.host/api/payment/stripe/verify?locale=en"
  }
=end
  def begin
    fail OrderPayError, 'order is already paid or canceled' unless @order.pending?
    log_with_current_user @order
    if free_check(@order)
      render json: { paid: true, message: 'Trigger order#pay!' }
    else
      render json: { webpay_url: verify_api_payment_stripe_url }
    end
  end

=begin
@api {post} /api/payment/stripe/verify Run and Verify Stripe payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentStripe
@apiName VerifyPaymentStripe
@apiParam {String} card_token Stripe Card Token for paid only used for once
@apiParam {String} order_no Order's order_no
@apiParam {String} uuid Order's uuid
@apiSuccessExample {json} Success-Response:
  {
    paid: 'true', message: 'Trigger order#pay!'
  }
=end
  def verify
    fail ApplicationError unless @order.paid? || @order.may_pay?
    log_with_current_user @order
    if @order.paid?
      render json: { paid: true, message: 'The order is already paid' }
    else
      fail ApplicationError, 'card_token missing' unless params[:card_token].present?
      payment = find_payment(params[:card_token])
      if payment.execute
        render json: { paid: true, message: 'Trigger order#pay!' }
      else
        render json: { paid: false, message: payment.error }, status: :bad_request
      end
    end
  end

=begin
@api {get} /api/payment/paypal/retrieve Retrieve Stripe payment object
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentStripe
@apiName RetrievePaymentStripe
@apiParam {String} order_no Order's order_no
@apiParam {String} uuid Order's uuid
@apiSuccessExample {json} Success-Response:
  {
                     "id" => "test_ch_3",
                 "object" => "charge",
                "created" => 1366194027,
               "livemode" => false,
                   "paid" => true,
                 "amount" => 9990,
               "currency" => "USD",
               "refunded" => false,
                    "fee" => 0,
            "fee_details" => [],
                   "card" => {
                         "id" => "test_cc_2",
                     "object" => "card",
                      "last4" => "4242",
                       "type" => "Visa",
                      "brand" => "Visa",
                  "exp_month" => 9,
                   "exp_year" => 2018,
                "fingerprint" => "eXWMGVNbMZcworZC",
                   "customer" => "test_cus_default",
                    "country" => "US",
                       "name" => "Johnny App",
              "address_line1" => nil,
              "address_line2" => nil,
               "address_city" => nil,
              "address_state" => nil,
                "address_zip" => nil,
            "address_country" => nil,
                  "cvc_check" => nil,
        "address_line1_check" => nil,
          "address_zip_check" => nil,
                     "number" => "4242424242424242",
                        "cvc" => "999"
    },
               "captured" => true,
                "refunds" => {
             "object" => "list",
        "total_count" => 0,
           "has_more" => false,
                "url" => "/v1/charges/test_ch_3/refunds",
               "data" => []
    },
    "balance_transaction" => "test_txn_1",
        "failure_message" => nil,
           "failure_code" => nil,
        "amount_refunded" => 0,
               "customer" => nil,
                "invoice" => nil,
            "description" => "1511137600013US",
                "dispute" => nil,
               "metadata" => {},
          "receipt_email" => "sunny@gmail.com"
}
=end
  def retrieve
    fail ApplicationError unless @order.paid?
    render json: Stripe::Charge.retrieve(@order.payment_id)
  rescue Stripe::InvalidRequestError
    fail ActiveRecord::RecordNotFound
  end

  protected

  def find_payment(card_token)
    Stripe::ChargeService.new(@order, card_token)
  end
end
