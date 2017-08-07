#= require redeem
window.getLocale = () ->
  locale = 'en'
  tmp = $('body').attr('class').match('locale-[a-zA-Z-]+')
  locale = tmp[0].replace('locale-','') if tmp.length > 0
  return locale

@LoadingImage =
  show: (selector) ->
    selector.find('span').addClass('opacity_hide')
    selector.find('.loading_image').removeClass('hide')
  hide: (selector) ->
    selector.find('span').removeClass('opacity_hide')
    selector.find('.loading_image').addClass('hide')


$(document).on 'ready page:load', ->
  targetError = (target, text)->
    target.closest('.form-group').addClass('form-valid-error').append("<span class='error'>#{text}</span>")

  validateShippingInfo =  (shippingForm) ->
    shippingForm = shippingForm || $('#redeem-shipping-info')
    isOk = true

    if !!getLocale().match(/zh/)
      required_text = '*必填'
    else
      required_text = '*required'

    if !!getLocale().match(/zh/)
      invalid_email_text = '*必須為正確的email格式'
    else
      invalid_email_text = '*E-mail is in invalid format'

    if !!getLocale().match(/zh/)
      invalid_integer_text = '*必須為數字'
    else
      invalid_integer_text = '*must be an integer'

    target = $('#shipping_info_name', shippingForm)
    val = target.val()
    unless val && val.length
      isOk = false
      targetError(target, required_text)

    target = $('#shipping_info_email', shippingForm)
    val = target.val()
    unless val && val.length&& val.match(/[^\s]+@[^\s]+\.[a-zA-Z]+$/)
      isOk = false
      $('#shipping_info_email').removeAttr('placeholder')
      targetError(target, invalid_email_text)

    target = $('#shipping_info_address', shippingForm)
    val = target.val()
    unless val && val.length
      isOk = false
      targetError(target, required_text)

    target = $('#redeem-shipping_info-country-code', shippingForm)
    val = target.val()
    unless val && val.length
      isOk = false
      targetError(target, required_text)

    target = $('#shipping_info_state', shippingForm)
    val = target.val()
    unless val && val.length
      isOk = false
      targetError(target, required_text)

    target = $('#shipping_info_zip_code', shippingForm)
    val = target.val()
    if val && val.length
      unless val.match /^\d+$/
        isOk = false
        targetError(target, invalid_integer_text)

    target = $('#shipping_info_phone', shippingForm)
    val = target.val()
    unless val && val.length && val.match(/[+\d-]+/)
      isOk = false
      targetError(target, invalid_integer_text)

    return isOk

  if $('.event-list').data('backgroundImage')?
    $('.event-list').css('background-image', $('.event-list').data('backgroundImage'))

  $(document).on 'click', '.form-valid-error', ->
    $(this).removeClass('form-valid-error').find('span').remove()

  $(document).on 'keyup touchend', 'input#redeem_input', ->
    $this = $(this)
    $('#redeem_input, .redeem-coupon-valide').removeClass('redeem-valid-error')
    $('#redeem-valid-error-ticker').addClass('hide')
    if $this.val().length > 0
      $('button.redeem-coupon-valide').removeClass('disabled')
      $('button.redeem-coupon-valide').attr('disabled', false)
      $('#redeem-remove').removeClass('hide')
    if $this.val().length == 0
      $('button.redeem-coupon-valide').addClass('disabled')
      $('button.redeem-coupon-valide').attr('disabled', true)
      $('#redeem-remove').addClass('hide')

  $(document).on 'click', 'img#redeem-remove', ->
    $('input#redeem_input').val('')
    $('button.redeem-coupon-valide').addClass('disabled')
    $('button.redeem-coupon-valide').attr('disabled', true)
    $('#redeem-code').removeClass('redeem-valid-error')
    $(this).addClass('hide')

  $(document).on 'click touchend', 'button.redeem-coupon-valide', ->
    LoadingImage.show($(this))

  $(document).on 'submit', '.redeem-coupon-form', (e) ->
    Redeem.verifyCodeBdevent($('#redeem_input').val(), $('#bdevent_id').val(), 'mobile-campaign')
    return false

  $(document).on 'click touchend', 'a.footer-like[disabled!=disabled]', () ->
    $form = $('#redeem-shipping-info')
    $('.form-group', $form).each -> $(this).css('border-color': '')
    return false unless validateShippingInfo($form)
    LoadingImage.show($(this))
    $form.submit()

  $('.simple-back').on 'click', ->
    window.history.go(-1)

  $(document).on 'click', '.redeem_work', ->
    $(".redeem-works-preview-container[data-uuid=#{$(this).data('uuid')}]").addClass('poped').css('z-index', 99)
    $('.leftnavs:first').hide()
    return false

  $('.redeem-preview-back').on 'click', ->
    $(this).parents('.redeem-works-preview-container:first').removeClass('poped')
    $('.leftnavs:first').show()

  $(document).on 'change', '[name*=shipping_info]', () ->
    tmp = $('[name*=shipping_info]').map ->
             if @value == ''
               return 1
    if tmp.size() == 1
      $('a.footer-like').removeAttr('disabled').removeClass('disabled')

