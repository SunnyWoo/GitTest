class Api::V3::Payment::NewebMmkController < Api::V3::Payment::NewebController
=begin
@api {get} /api/payment/neweb_mmk/begin Begin neweb MMK payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentNewebMMK
@apiName BeginPaymentNewebMMK
@apiParam {String} uuid Order uuid
@apiParam {String} order_no Order order_no
@apiSuccessExample {json} Success-Response:
  {
    "payment_method": "neweb/atm",
    "pay_code": "12345678"
  }
=end
end
