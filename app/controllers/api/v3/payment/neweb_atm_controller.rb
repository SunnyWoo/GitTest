class Api::V3::Payment::NewebAtmController < Api::V3::Payment::NewebController
=begin
@api {get} /api/payment/neweb_atm/begin Begin neweb Atm payment
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup PaymentNewebATM
@apiName BeginPaymentNewebATM
@apiParam {String} uuid Order uuid
@apiParam {String} order_no Order order_no
@apiSuccessExample {json} Success-Response:
  {
    "payment_method": "neweb/atm",
    "bank_id": "007",
    "bank_name": "龐德銀行",
    "virtual_account": "7999911220004830"
  }
=end
end
