# 編輯器左方 Panel UI

$(document).ready ->
  # 關閉 Panel
  $('.close-panel').on 'click', ->
    $('.panel-box').removeClass('fadeInLeft').addClass('fadeOutLeft')
    setTimeout( ->
      $('.panel-box').addClass('hide')
      return
    , 500)
    return

  $('#drawing').on 'click', ->
    $('.close-panel').trigger 'click'
    return

  # 回上一步 Panel
  $('.prev-step').on 'click', ->
    target = $(this).attr('data-target')
    $(target).removeClass('fadeInLeft').addClass('fadeOutLeft')
    setTimeout( ->
      $(target).addClass('hide')
      return
    , 500)
    $('#chooseObj').removeClass('hide fadeOutLeft').addClass('fadeInLeft')
    return

  # 互叫第二層 Panel
  $('.obj[data-type=list]').on 'click', ->
    target = $(this).attr('data-target')
    $('#chooseObj').removeClass('fadeInLeft').addClass('fadeOutLeft')
    $(target).removeClass('hide fadeOutLeft').addClass('fadeInLeft')
    # $('.custom-scrollbar').mCustomScrollbar("scrollTo","top")
    return

  # 呼叫 Popup 類型
  $('.obj[data-type=popup]').on 'click', ->
    $('#chooseObj').removeClass('fadeInLeft').addClass('fadeOutLeft')
    setTimeout( ->
      $('#chooseObj').addClass('hide')
      return
    , 500)
    # $('#upload_init').modal({ backdrop: 'static', show: true })
    $('#upload_from_computer').modal({ backdrop: 'static', show: true })
    return

  # 呼叫 素材(sticker, typography, shapes) 類型 
  $('.obj[data-type=obj]').on 'click', ->
    $('.panel-box').removeClass('fadeInLeft').addClass('fadeOutLeft')
    setTimeout( ->
      $('.panel-box').addClass('hide')
      return
    , 500)
    obj =
      data:      $(this).attr('data-obj')
      data_name: $(this).attr('data-obj-name')
      prop:      $(this).attr('data-prop')
    cmdp.addc('obj', obj)
    return

  # 呼叫 文字 類型
  $('.obj[data-type=text]').on 'click', ->
    $('#input-text').val('Hello!')
    $('.panel-box').removeClass('fadeInLeft').addClass('fadeOutLeft')
    setTimeout( ->
      $('.panel-box').addClass('hide')
      return
    , 500)
    obj =
      data:      $('.font-current').text()
      data_name: null
      prop:      $(this).attr('data-prop')
    cmdp.addc('text', obj)
    return

  # 呼叫 單底色 類型
  $('.obj[data-type=bg]').on 'click', ->
    $('.panel-box').removeClass('fadeInLeft').addClass('fadeOutLeft')
    setTimeout( ->
      $('.panel-box').addClass('hide')
      return
    , 500)
    obj =
      data:      '#000000'
      data_name: null
      prop:      $(this).data('prop')
    cmdp.addc('bg', obj)
    return