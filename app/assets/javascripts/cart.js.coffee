@CheckOut =
  updateCountryCode: (country_code) ->
    $.ajax
      async: false
      url: "/#{getLocale()}/cart/check_out_update.js",
      type: 'patch',
      data:
        attr: 'country_code'
        val: country_code

  checkCashOnDelivery: (country_code)->
    radio = $("input#order_payment_cash_on_delivery")
    if country_code == "TW"
      radio.parent().removeClass('hide')
    else
      if radio.attr('checked') == 'checked'
        radio.parents('form').find('[type=radio]:first').click()
      radio.parent().addClass('hide')


  verifyCoupon: (page) ->
    $.ajax
      url: "/#{getLocale()}/cart/coupon.js",
      type: 'post',
      data: { coupon_code: $('#coupon_code').val(), page: page }

  clearCoupon: ->
    $.ajax
      url: "/#{getLocale()}/cart/coupon.js",
      type: 'delete',
      data: { clear_coupon_code: true }

  clineCheckForm: (form_obj)->
    is_valid = []
    $.each form_obj.find('input').get().reverse(), ->
      $div = $(this).parent()
      $error = $div.find('.error')
      judge.validate this,
        valid: (element) ->
          is_valid.push true
          $error.html('')
          $div.addClass('required')

        invalid: (element, messages) ->
          is_valid.push false
          $error.html(messages.join(",")).focus()
          element.focus()
          $div.removeClass('required')

    country_code = form_obj.find('.country_code select').val()
    $.each $('.validate_with_english'), ->
      $div = $(this).parent()
      $error = $div.find('.error')
      if $(this).val().match('[^\u0000-\u007F]+') != null && !(country_code in ['HK', 'CN', 'JP', 'MO', 'TW'])
        is_valid.push false
        $error.html($(this).data('error-msg')).focus()
      else
        is_valid.push true
        $error.html('')

    return is_valid.join().match(/false/) == null

  syncAddressInfo: ->
    $.each $('#new_shipping_info input, #new_billing_info input'), ->
      $("form#check_out #order_#{this.id}").val(this.value)
    $.each $('#new_shipping_info select, #new_billing_info select'), ->
      $("form#check_out #order_#{this.id}").val(this.value)

  checkSubmit: ->
    CheckOut.syncAddressInfo()

    if $('.select_address').length > 0 || $('#new_shipping_info').length == 0
      if $('.select_address[data-to=order_shipping_info]:checked').length == 0
        $('.select_address[data-to=order_shipping_info]').focus()
        $('#order_shipping_info_address_info_error').removeClass('hide')
        return false
      else
        $('.select_address[data-to=order_shipping_info]:checked').click()

      if $('.select_address[data-to=order_billing_info]:checked').length == 0
        $('.select_address[data-to=order_billing_info]').focus()
        $('#order_billing_info_address_info_error').removeClass('hide')
        return false
      else
        $('.select_address[data-to=order_billing_info]:checked').click()
    else
      if !CheckOut.clineCheckForm($('#new_shipping_info'))
        $('#new_shipping_info input[type=text]').first().focus()
        return false

      if !CheckOut.clineCheckForm($('#new_billing_info'))
        $('#new_billing_info input[type=text]').first().focus()
        return false

    return true

$(document).on 'page:change',  ->
  if $('input.select_address:checked').length > 0
    setTimeout () ->
      $('input.select_address:checked').click()
    , 500
    $.each $('input.select_address:checked'), ->
      $(this).parent().find('.address_info_block').removeClass('hide')

$ ->
  #change cart itemt qty
  $(document).on 'click', 'li[role=update_qty]', ->
    $(this).parent().find('span.val').text($(this).text())
    $.ajax
      url:"/#{getLocale()}/cart/#{$(this).find('.i').data('uuid')}.js",
      type: "put",
      data: { q: $(this).text() }

  #verify coupon
  $(document).on 'click', '#check_out_summery #verify_coupon', ->
    CheckOut.verifyCoupon('check_out_update')

  #clear coupon
  $(document).on 'click', '#check_out_summery #clear_coupon', ->
    CheckOut.clearCoupon()

  #check out - select address
  $(document).on 'click', '.select_address', ->
    $(this).parents('ul').find('[id*=address_info_block]').addClass('hide')
    $(this).parents('ul').find("#address_info_block_#{this.value}").removeClass('hide')
    $(this).parents('ul').find("[id*=address_info_form]").hide()
    to = $(this).data('to')

    $("##{to}_address_info_error").addClass('hide')
    form_inputs = $(this).parents('li').find('form input[name*=address_info],
      form select')

    if to == 'order_shipping_info'
      select_country_code = $("#address_info_form_#{this.value} #address_info_country_code").val()
      CheckOut.updateCountryCode(select_country_code)

    $.each form_inputs, ->
      id = this.id.replace('address_info', to)
      $("form#check_out ##{id}").val(this.value)

  $(document).on 'change', 'select#shipping_info_country_code', ->
    if $(this).data('attr')
      CheckOut.updateCountryCode(this.value)

  #for checkout ppage - check_out_update
  $(document).on 'click', '.check_out_update', ->
    attr = $(this).data('attr')
    val = this.value
    val = val.replace('/', '_') if val.match('/')
    id = this.id.replace("_#{val}",'')
    $("form#check_out ##{id}").val(this.value)
    $.ajax
      async: false
      url: "/#{getLocale()}/cart/check_out_update.js",
      type: 'patch',
      data: { attr: attr , val: this.value }
    if attr == 'payment'
      cashOnDeliveryRadio = $('[data-attr=shipping_way][value=cash_on_delivery]')
      if val == 'cash_on_delivery'
        cashOnDeliveryRadio.parent().removeClass('hide')
        cashOnDeliveryRadio.click()
        cashOnDeliveryRadio.parents('ul').find('input[type=radio]').attr('disabled', true)
      else
        shipping_radios = cashOnDeliveryRadio.parents('ul').find('input[type=radio]')
        shipping_radios.attr('disabled', false)
        if $('[name="order[shipping_info][shipping_way]"]:checked').val() == 'cash_on_delivery'
          shipping_radios.first().click()
          cashOnDeliveryRadio.parent().addClass('hide')

  #check out new shipping info
  $(document).on 'blur', '.new_shipping_info input, .new_billing_info input', ->
    id = "order_#{this.id}"
    $("form#check_out ##{id}").val(this.value)

  #check out - same_as_shipping_info
  $(document).on 'change', '#same_as_shipping_info', ->
    if this.checked
      $.each $('form#new_shipping_info input'), ->
        id = this.id.replace('shipping_info', 'billing_info')
        $("##{id}").val this.value
      $('form#new_billing_info select').val( $('form#new_shipping_info select').val() )
    else
      $("form#new_billing_info input").val('')

  #check out - summary button
  $(document).on 'click', '#check_out_summary', ->
    if !CheckOut.checkSubmit()
      return false
    local = window.location.pathname.split("/")[1]

    $('form#check_out').submit()

    return false

  #check out - check create address info
  $(document).on 'submit', '#new_address_info', ->
    if !CheckOut.clineCheckForm($(this))
      return false
