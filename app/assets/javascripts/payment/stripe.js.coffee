# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require jquery.validate
#= require jquery.validate.additional-methods

jQuery ($) ->
  order =
    setupForm: ->
      $('#new_order_stripe').submit ->
        # $('input[type=submit]').attr('disabled', true)
        order.processCard()
      $('#new_order_stripe_submitbut').on 'click touch', ->
        # $('input[type=submit]').attr('disabled', true)
        order.processCard()

    processCard: ->
      cardNumber = $('#card_number_1').val() + $('#card_number_2').val() + $('#card_number_3').val() + $('#card_number_4').val() || $('#card_number_all').val()
      card =
        number: cardNumber
        cvc: $('#card_code').val()
        expMonth: $('#card_month').val()
        expYear: $('#card_year').val()
      Stripe.createToken(card, order.handleStripeResponse)

    handleStripeResponse: (status, response) ->
      if status == 200
        $('#order_stripe_card_token').val(response.id)
        $('#new_order_stripe')[0].submit()
      else
        $('#stripe_error').text('Stripe: '+response.error.message)
        $('input[type=submit]').attr('disabled', false)

  jQuery.validator.setDefaults
    debug: true
    success: "valid"

  $("#new_order_stripe").validate
    rules:
      card_number_1:
        required: true
        digits: true
      card_number_2:
        required: true
        digits: true
      card_number_3:
        required: true
        digits: true
      card_number_4:
        required: true
        digits: true
      card_code:
        required: true
        digits: true
      card_month:
        required: true
        max: 12
      card_year:
        required: true
        digits: true
    messages:
      card_number_1: 'Credit card number is invalid!'
      card_number_2: 'Credit card number is invalid!'
      card_number_3: 'Credit card number is invalid!'
      card_number_4: 'Credit card number is invalid!'
      card_code: 'CVC is invalid!'
      card_month: 'Expiration date is invalid!'
      card_year: 'Expiration date is invalid!'
    errorPlacement: (error, e) =>
      $(e).parent().find('.error').html(error)
      return

  $('.order-sprite .input-col').on 'keyup', (e)->
    target = e.srcElement
    maxLength = parseInt(target.attributes["maxlength"].value, 10)
    myLength = target.value.length
    if myLength >= maxLength
      next = target
      while next = next.nextElementSibling
        break  unless next?
        if next.tagName.toLowerCase() is "input"
          next.select()
          break
    return

  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  order.setupForm()
