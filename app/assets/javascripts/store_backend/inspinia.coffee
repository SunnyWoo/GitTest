###
  INSPINIA Theme Script

  只啟用專案需要用到的功能，INSPINIA Theme 所有功能可以看 inspinia.js.origin
###

Turbolinks.enableProgressBar()

# check if browser support HTML5 local storage
localStorageSupport = ->
  'localStorage' of window and window['localStorage'] != null

SmoothlyMenu = ->
  if !$('body').hasClass('mini-navbar') or $('body').hasClass('body-small')
    # Hide menu in order to smoothly turn on when maximize menu
    $('#side-menu').hide()
    # For smoothly turn on menu
    setTimeout (->
      $('#side-menu').fadeIn 400
    ), 200
  else if $('body').hasClass('fixed-sidebar')
    $('#side-menu').hide()
    setTimeout (->
      $('#side-menu').fadeIn 400
    ), 100
  else
    # Remove all inline style from jquery fadeIn function to reset menu state
    $('#side-menu').removeAttr 'style'

$(document).on 'page:change', ->
  # Full height of sidebar
  fix_height = ->
    heightWithoutNavbar = $('body > #wrapper').height() - 61
    $('.sidebard-panel').css 'min-height', heightWithoutNavbar + 'px'
    navbarHeigh = $('nav.navbar-default').height()
    wrapperHeigh = $('#page-wrapper').height()
    if navbarHeigh > wrapperHeigh
      $('#page-wrapper').css 'min-height', navbarHeigh + 'px'
    if navbarHeigh < wrapperHeigh
      $('#page-wrapper').css 'min-height', $(window).height() + 'px'
    if $('body').hasClass('fixed-nav')
      if navbarHeigh > wrapperHeigh
        $('#page-wrapper').css 'min-height', navbarHeigh + 'px'
      else
        $('#page-wrapper').css 'min-height', $(window).height() - 60 + 'px'
    return

  # MetsiMenu
  $('#side-menu').metisMenu()

  # Collapse ibox function
  $('.collapse-link').on 'click', ->
    ibox = $(this).closest('div.ibox')
    button = $(this).find('i')
    content = ibox.find('div.ibox-content')
    content.slideToggle 200
    button.toggleClass('fa-chevron-up').toggleClass 'fa-chevron-down'
    ibox.toggleClass('').toggleClass 'border-bottom'
    setTimeout (->
      ibox.resize()
      ibox.find('[id^=map-]').resize()
      return
    ), 50
    return

  # Close ibox function
  $('.close-link').on 'click', ->
    content = $(this).closest('div.ibox')
    content.remove()
    return

  # Fullscreen ibox function
  $('.fullscreen-link').on 'click', ->
    ibox = $(this).closest('div.ibox')
    button = $(this).find('i')
    $('body').toggleClass 'fullscreen-ibox-mode'
    button.toggleClass('fa-expand').toggleClass 'fa-compress'
    ibox.toggleClass 'fullscreen'
    setTimeout (->
      $(window).trigger 'resize'
      return
    ), 100
    return

  # Run menu of canvas
  $('body.canvas-menu .sidebar-collapse').slimScroll
    height: '100%'
    railOpacity: 0.9

  # Initialize slimscroll for right sidebar
  $('.sidebar-container').slimScroll
    height: '100%'
    railOpacity: 0.4
    wheelStep: 10

  # Minimalize menu
  $('.navbar-minimalize').click ->
    $('body').toggleClass 'mini-navbar'
    SmoothlyMenu()
    return

  fix_height()

  # Fixed Sidebar
  $(window).bind 'load', ->
    if $('body').hasClass('fixed-sidebar')
      $('.sidebar-collapse').slimScroll
        height: '100%'
        railOpacity: 0.9
    return

  # Move right sidebar top after scroll
  $(window).scroll ->
    if $(window).scrollTop() > 0 and !$('body').hasClass('fixed-nav')
      $('#right-sidebar').addClass 'sidebar-top'
    else
      $('#right-sidebar').removeClass 'sidebar-top'
    return

  $(window).bind 'load resize scroll', ->
    if !$('body').hasClass('body-small')
      fix_height()
    return

  $('[data-toggle=popover]').popover()

  # Add slimscroll to element
  $('.full-height-scroll').slimscroll height: '100%'
  return

# Set proper body class and plugins based on user configuration
$(document).on 'page:change', ->
  # fixed sidebar
  $('body').addClass 'fixed-sidebar'
  $('.sidebar-collapse').slimScroll
    height: '100%'
    railOpacity: 0.9
