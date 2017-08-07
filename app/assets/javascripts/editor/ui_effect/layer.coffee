$(document).ready ->
  # 加圖層
  $('.add').on 'click', ->
    $('#chooseObj').removeClass('hide fadeOutLeft').addClass('fadeInLeft')
    return

  $('#add_overlay').on 'click', ->
    $('.add').trigger('click')
    return