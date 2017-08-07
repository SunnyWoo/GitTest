$(document).on 'ready page:load', ->
  if $('#pingpp_alipay_qrcode').length > 0
    checkPingppAlipayQrOrder()


checkPingppAlipayQrOrder = ->
  $.ajax
    url: "/#{getLocale()}/payment/pingpp_alipay_qr/pay_result"
    dataType: "json"
    type: 'get'
    data:
      'order_no': $('#order_no').val()
    success: (data) ->
      if data.paid
        window.location.href = "/#{getLocale()}/order_results/" + $('#order_no').val()
    setTimeout(checkPingppAlipayQrOrder, 5000)
