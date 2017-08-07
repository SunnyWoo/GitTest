@Redeem =
  verifyCode: (redeem_code, gid, template) ->
    $.ajax
      url: "/zh-TW/redeems/verify"
      type: 'post'
      dataType: 'json'
      data:
        redeem_code: redeem_code
        gid: gid
      error: (jqXHR, textStatus, errorThrown) ->
        Redeem.failureHandler(template)
    .done (e) ->
      if e.status
        Redeem.suceessHandler(template, redeem_code)
      else
        Redeem.failureHandler(template)

  verifyCodeBdevent: (redeem_code, bdeventId, template) ->
    $.ajax
      url: "/zh-TW/redeems/verify"
      type: 'post'
      dataType: 'json'
      data:
        redeem_code: redeem_code
        bdevent_id: bdeventId
      error: (jqXHR, textStatus, errorThrown) ->
        Redeem.failureHandler(template)
    .done (e) ->
      if e.status
        Redeem.suceessHandler(template, redeem_code)
      else
        Redeem.failureHandler(template)
  post: () ->
    $.ajax
      url: "/#{getLocale()}/redeems"
      type: 'post'
      data: $('#new_shipping_info').serialize()
    .done (e) ->
      if e.status
        location.href = "/#{getLocale()}/order_results/#{e.order_no}"
      else
        console.log e.error

  suceessHandler: (template, redeem_code = '') ->
    switch template
      when 'mobile-campaign'
        LoadingImage.hide($('button.redeem-coupon-valide'))
        $('#redeem-valid-error-ticker').addClass('hide')
        $('#redeem_input, .redeem-coupon-valide').attr('disabled', 'disabled').removeClass('redeem-valid-error')
        $('button.redeem-coupon-valide').text('').addClass('disabled').addClass('redeem-valid-success').attr('disabled', true)
        $('#shipping_info_redeem_code').val(redeem_code)
        $('#show').addClass('poped')
        $('body.android [data-success=hide]').addClass('hide')
      else
        $('.coupon_error').addClass('hide')
        $('.coupon_notice').removeClass('hide')
        $('#submit_redeem').removeAttr('disabled')
        $('#redeem_code').attr('readonly', 'readonly')
        $('#verify_redeem').attr('disabled', 'disabled')

  failureHandler: (template) ->
    switch template
      when 'mobile-campaign'
        LoadingImage.hide($('button.redeem-coupon-valide'))
        $('#redeem_input, .redeem-coupon-valide').addClass('redeem-valid-error')
        $('#redeem-valid-error-ticker').removeClass('hide')
      else
        $('.coupon_error').removeClass('hide')

$ ->
  $(document).on 'click', '#submit_redeem', ->
    unless CheckOut.clineCheckForm($('#new_shipping_info'))
      return false
    Redeem.post()
    return false

  $(document).on 'click', '#redeem_code', ->
    $('.coupon_error').addClass('hide')

  $(document).on 'click', '#verify_redeem', ->
    gid = $('#gid').val()
    redeem_code = $('#redeem_code').val()
    Redeem.verifyCode(redeem_code, gid, 'website-campign')
    return false
