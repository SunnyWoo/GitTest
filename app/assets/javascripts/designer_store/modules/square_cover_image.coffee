$(document).on 'page:change', ->
  $('[data-square-cover-image]').each ->
    width = $(this).width()
    $(this).height(width)
