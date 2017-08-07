$(document).scroll ->
  scroll_now = $(this).scrollTop();
  if(scroll_now >= 560)
    $('.careers #sidebar').css({
      'position': 'fixed',
      'top': '30px'
      })
    $('.careers #article').css({
      'margin-left': '360px'
      })
    if(scroll_now >= 6860)
      fixed_position = -(scroll_now - 6860) + 30
      $('.careers #sidebar').css({
        'top': fixed_position + 'px'
        })
  else
    $('.careers #sidebar').attr('style', '')
    $('#article').attr('style', '')
  return
