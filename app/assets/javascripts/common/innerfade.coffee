#= require plugins/jquery.innerfade

$(document).on 'ready page:change', ->
  if $('#announcement').length > 0
    $('#announcement').innerfade
      speed: 'slow'
      timeout: 5000
      type: 'sequence'
      containerheight: '2em'

$(document).on 'page:before-unload', ->
  $('#announcement').innerfade('stop')
