window.Commandp.Ua ||= {}
window.Commandp.Ua.Purchase ||= {}

class Commandp.Ua.Purchase
  constructor: (@element) ->
    @orderNo = @element.data('orderno')
    @price = @element.data('price')
    @coupon = @element.data('coupon')
    @payment = @element.data('payment')
    @affiliation = @element.data('affiliation')

  onPurchase: ->
    taxFee = parseFloat(@price * 0.05, 10)
    ga "ec:setAction", "purchase",
      id: @orderNo
      affiliation: @affiliation
      revenue: parseFloat(@price, 10) - taxFee
      tax: taxFee
      shipping: "0.00"
      coupon: @coupon
      option: @payment

    return

$(document).on 'ready page:load', ->
  if ga?
    $('.ga_purchase_data').each ->
      new Commandp.Ua.Purchase($(this)).onPurchase()

  return
