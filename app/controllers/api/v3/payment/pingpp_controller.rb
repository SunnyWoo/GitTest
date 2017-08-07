class Api::V3::Payment::PingppController < ApiV3Controller
  include PingppMethods

  before_action :doorkeeper_authorize!, :check_user
  before_action :find_order, :find_channel, only: [:begin]
  before_action :find_order_for_verify, :find_pingpp_charge, only: [:verify, :retrieve]

=begin
@api {get} /api/payment/pingpp/begin Begin pingpp payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentPingpp
@apiName BeginPaymentPingpp
@apiParam {String} uuid Order uuid
@apiParamExample {json} Request-Example
GET /api/payment/pingpp/begin
  {
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
    "subject": "commandp 噗印商品",
    "body": "commandp 噗印商品",
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
        "orderInfo": "_input_charset=\"utf-8\"&body=\"commandp 噗印商品\"&it_b_pay=\"1440m\""
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
@api {post} /api/payment/pingpp/verify Verify Pingpp Payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentPingpp
@apiName VerifyPaymentPingpp
@apiParam {String} uuid Order uuid
@apiParamExample {json} Request-Example
  POST /api/payment/pingpp/verify
  {
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

=begin
@api {get} /api/payment/pingpp/retrieve Retrieve Charge
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentPingpp
@apiName RetrieveCharge
@apiParam {String} uuid Order uuid
@apiParamExample {json} Request-Example
GET /api/payment/pingpp/retrieve
  {
    "uuid": "1b9a54fc-5a59-11e4-865e-3c15c2d24fd8"
  }
@apiSuccessExample {json} Success-Response:
  {
    "id": "ch_L8qn10mLmr1GS8e5OODmHaL4",
    "object": "charge",
    "created": 1410834527,
    "livemode": true,
    "paid": false,
    "refunded": false,
    "app": "app_1Gqj58ynP0mHeX1q",
    "channel": "upacp",
    "order_no": "123456789",
    "client_ip": "127.0.0.1",
    "amount": 100,
    "amount_settle": 0,
    "currency": "cny",
    "subject": "Your Subject",
    "body": "Your Body",
    "extra":{},
    "time_paid": null,
    "time_expire": 1410838127,
    "time_settle": null,
    "transaction_no": null,
    "refunds": {
      "object": "list",
      "url": "/v1/charges/ch_L8qn10mLmr1GS8e5OODmHaL4/refunds",
      "has_more": false,
      "data": []
    },
    "amount_refunded": 0,
    "failure_code": null,
    "failure_msg": null,
    "metadata": {},
    "credential": {
      "object": "credential",
      "upacp": {
        "tn": "201409161028470000000",
        "mode": "01"
      }
    },
    "description": null
  }
=end

  protected

  def find_order
    @order = current_user.orders.find_by!(uuid: params[:uuid] || params[:order_uuid])
    fail OrderPayError, 'order currency should be CNY' unless @order.currency == 'CNY'
  end
end
