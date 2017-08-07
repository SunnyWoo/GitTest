class Api::V2::Payment::PingppController < ApiV2Controller
  include PingppMethods

  before_action :authenticate_required!
  before_action :find_order, :find_channel, only: [:begin]
  before_action :find_order_for_verify, :find_pingpp_charge, only: [:verify]

=begin
@api {get} /api/payment/pingpp/begin Begin pingpp payment
@apiUse NeedAuth
@apiGroup PaymentPingpp
@apiName BeginPaymentPingpp
@apiVersion 2.0.0
@apiParam {String} uuid Order uuid
@apiParamExample {json} Request-Example
  GET /api/payment/pingpp/begin
  {
    "auth_token": 'a_valid_token',
    "uuid": "1b9a54fc-5a59-11e4-865e-3c15c2d24fd8"
  }
@apiSuccessExample {json} Success-Response:
  {
    "id": "ch_1GWnn5P4ir5Crz1mj984GGe9",
    "object": "charge",
    "created": 1438163773,
    "livemode": false,
    "paid": false,
    "refunded": false,
    "app": "app_u9ujT414KeXTLaLO",
    "channel": "alipay",
    "order_no": "157T000169US",
    "client_ip": "0.0.0.0",
    "amount": 540000,
    "amount_settle": 0,
    "currency": "cny",
    "subject": "commandp 我印商品",
    "body": "commandp 我印商品",
    "extra": {
    },
    "time_paid": null,
    "time_expire": 1438250173,
    "time_settle": null,
    "transaction_no": null,
    "refunds": {
      "object": "list",
      "url": "/v1/charges/ch_1GWnn5P4ir5Crz1mj984GGe9/refunds",
      "has_more": false,
      "data": [

      ]
    },
    "amount_refunded": 0,
    "failure_code": null,
    "failure_msg": null,
    "metadata": {
    },
    "credential": {
      "object": "credential",
      "alipay": {
        "orderInfo": "_input_charset=\"utf-8\"&body=\"commandp 我印商品\"&it_b_pay=\"1440m\""
      }
    },
    "description": null
  }
@apiSuccessExample {json} Response(0元订单):
  {
    "paid": true,
    "message": "Trigger order#pay!"
  }
=end

=begin
@api {get} /api/payment/pingpp/verify Verify Pingpp Payment
@apiUse NeedAuth
@apiGroup PaymentPingpp
@apiName VerifyPaymentPingpp
@apiVersion 2.0.0
@apiParam {String} uuid Order uuid
@apiParamExample {json} Request-Example
  GET /api/payment/pingpp/begin
  {
    "auth_token": 'a_valid_token',
    "uuid": "1b9a54fc-5a59-11e4-865e-3c15c2d24fd8"
  }
@apiSuccessExample {json} Response(尚未付款):
  {
    "paid": false,
    "message": "Pingpp::Charge is not paid yet"
  }
@apiSuccessExample {json} Response(已付款):
  {
    "paid": true,
    "message": "Trigger order#pay!"
  }
=end

  protected

  def find_order
    @order = current_user.orders.find_by!(uuid: params[:uuid] || params[:order_uuid])
    fail OrderPayError, 'order currency should be CNY' unless @order.currency == 'CNY'
  end
end
