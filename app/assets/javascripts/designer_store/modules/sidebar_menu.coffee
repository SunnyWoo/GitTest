$(document).on 'page:change', ->
  $goToTopBtn = $('.sidebarMenu-option-item--goToTop')
  $infoBtn = $('.sidebarMenu-option-item--info')
  $infoSection = $('.sidebarMenu .info')
  $body = $('body')
  $window = $(window)
  documentHeight = $(document).height()
  windowHeight = $(window).height()

  # show goToTopBtn when the scrollY axis ends
  $window.on 'scroll', () ->
    topOffset = $body.scrollTop()
    if topOffset > 2000
      $goToTopBtn.removeClass('hidden')
    else
      $goToTopBtn.addClass('hidden')

  # scroll to top
  $goToTopBtn.on 'click', () ->
    $body.animate({
      scrollTop: 0
    }, 300)

  # toggle info section
  $infoBtn.on 'click', () ->
    $infoSection.toggleClass('hidden')
