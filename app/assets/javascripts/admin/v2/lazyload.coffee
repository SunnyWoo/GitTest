$(document).on 'ready page:load', ->
  $('img.lazy').lazyload effect: 'fadeIn'
  return