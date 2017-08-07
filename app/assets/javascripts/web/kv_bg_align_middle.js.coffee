kvWidth = 1020
kvHeight = 500

rePositionAllKvBg = ->
  documentWidth = $(document).width()
  if documentWidth > kvWidth
    newMarginTop = - ( documentWidth / kvWidth * kvHeight - kvHeight) / 2
  else
    newMarginTop = 0

  $('.carousel-img').css('marginTop', "#{newMarginTop}px")

jQuery ($) ->
  rePositionAllKvBg()

  $(document).on 'ready page:load', ->
    $(window).resize(rePositionAllKvBg)
