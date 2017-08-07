#= require plugins/jquery.lazyload

$(document).on 'ready page:load', ->
  $("img.lazy").lazyload(effect: 'fadeIn')
