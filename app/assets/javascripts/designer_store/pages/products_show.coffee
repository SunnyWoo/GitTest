$(document).on 'page:change', ->
  return if $('body.products_controller.show_action').length == 0

  $('[data-product]').ecProductDetailView()

  if $('[data-widget-slick] img').length > 0
    $('[data-widget-slick]').not('.slick-initialized').slick
      dots: true,
      arrows: false

  $('.calculator-item--minus').hide()

  $('.calculator-item--plus').on 'click', () ->
    $result = $('.calculator-item--result')
    $minus = $('.calculator-item--minus')
    $minusShadow = $('.calculator-item--minusShadow')

    amountNum = +$result.text()

    $minus.show()
    $minusShadow.hide()
    $result.text(amountNum + 1)

  $('.calculator-item--minus').on 'click', () ->
    $result = $('.calculator-item--result')
    $minus = $('.calculator-item--minus')
    $minusShadow = $('.calculator-item--minusShadow')

    amountNum = +$result.text()

    if amountNum is 2
      $minus.hide()
      $minusShadow.show()

    $result.text(amountNum - 1)
