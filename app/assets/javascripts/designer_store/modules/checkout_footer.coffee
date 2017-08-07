$(document).on('click', '[data-checkout-footer-add-item]', ->
  quantity = parseInt($('[data-quantity]').text())
  $btn = $(this)
  $btn.attr('disabled', true)

  $.ajax(
    url: "/#{sliceLocaleFromUrl()}/#{jsPageData.storeId}/cart/add"
    type: 'POST'
    data:
      quantity: quantity
      id: jsPageData.workUuid
    success: (data) ->
      $('[data-checkout-footer-cart]').attr('number', data.meta.total_quantity)
      $('[data-remove-after-add-item-success]').remove()
      $('[data-display-after-add-item-success]').show()
      $btn.ecProductAdd quantity: quantity
    complete: ->
      $btn.attr('disabled', false)
  )
)
