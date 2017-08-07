$(document).on 'page:change', ->
  $('.tab-container').each ->
    minContentHeght = $(window).height() - $('.tab-list').height() - $('.checkoutFooter').height()

    $(this).find('.tab-content').each ->
      $(this).height(minContentHeght) if $(this).height() < minContentHeght

  $('.tab-list .tab').on 'click', (e)->
    $clickedTab = $(this)
    $shouldShowContent = $(".tab-content##{$clickedTab.data('tabName')}")
    $clickedTab.addClass('active').siblings('.active').removeClass('active')
    $shouldShowContent.addClass('active').siblings('.active').removeClass('active')
    initDescriptionImages($shouldShowContent)
    return

initDescriptionImages =  (container) ->
  $container = $(container)
  $descriptionImageBlock = $('#description-image')
  $images = $container.find('#description-image img')
  if $images.length > 0
    $images.each ->
      width = $('body').width()
      height = width / 2

      $(this)
        .width(width)
        .height(height)

    $descriptionImageBlock.not('.slick-initialized').slick
      dots: false,
      autoplay: true,
      autoplaySpeed: 2000,
      arrows: false
