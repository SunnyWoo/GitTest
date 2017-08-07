$(document).ready ->
  # Header Dropdown
  $('.header .profile-btn').hover ->
    offset = $(this).position()
    $('.profile_dropdown').removeClass('hide').css({
      'top': offset.top + 25 + 'px',
      'left': offset.left + 'px'
      })
    return
  , ->
    $('.profile_dropdown').addClass('hide')
    return

  return