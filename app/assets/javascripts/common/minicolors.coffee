#= require jquery.minicolors
#= require jquery.minicolors.simple_form

$(document).on 'page:change',  ->
  $('[data-minicolors]').each () ->
    input = $(this)
    input.minicolors(input.data('minicolors'))
