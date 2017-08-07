$(document).on 'page:change', ->
  $('.header-item--menu').on 'click', ->
    $('#burgerMenuButton').toggleClass 'open'
    $('.burgerMenu').toggleClass 'burgerMenu--triggered'
    if $('.burgerMenu').hasClass 'burgerMenu--triggered'
      $('[data-trigger-hide="#menu-mask"]').hide()
