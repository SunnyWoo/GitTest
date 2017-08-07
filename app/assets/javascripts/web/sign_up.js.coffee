$(document).on 'ready page:load', ->
  verifyCaptcha = false

  $('.tab-bg').on 'click', ->
    $tab = $(this).find('a.tab')
    selector = $tab.attr('href')
    selector = selector && selector.replace(/.*(?=#[^\s]*$)/, '')
    $selector = $(selector)
    if $selector.is(':visible')
      return
    $('.login_form').addClass('hide')
    $selector.removeClass('hide')
    $('.tab-bg').removeClass('active')
    $(this).addClass('active')
    $('.login_form:hidden form')[0].reset()
    $('.error').remove()

  $('.login_form#mobile .captcha').on 'keyup', ->
    captcha = $(this).val()
    if captcha.length == 5
      $.ajax
        url: "/#{getLocale()}/captcha/verify"
        dataType: "json"
        type: 'get'
        data:
          'captcha': captcha
        success: (data) ->
          if data.success
            verifyCaptcha = true
            $('.send-code').removeAttr('disabled')
          else
            console.log 'fail'
        error: (data) ->
          console.log 'Update error!!'

  $('.login_form#mobile .send-code').on 'click', ->
    mobile = $('#user_mobile').val()
    if verifyCaptcha
      $.ajax
        url: "/#{getLocale()}/mobile/code"
        dataType: "json"
        type: 'get'
        data:
          'mobile': mobile
        success: (data) ->
          if data.success
            waitMobileCode(60)
          else
            console.log 'fail'
        error: (data) ->
          console.log 'Update error!!'
  return

waitMobileCode = (countDown) ->
  sendCodeBtn = $('.login_form#mobile .send-code')
  sendCodeBtn.attr('disabled', 'disabled')
  setTimeout =>
    if countDown isnt 0
      countDown--
      sendCodeBtn.html(countDown + '秒后重新发送')
      waitMobileCode(countDown)
    else
      sendCodeBtn.removeAttr('disabled').text('发送验证码')
  , 1000

  return
