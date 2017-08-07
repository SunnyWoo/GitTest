#= require plugins/jquery.autosize-min

$(document).on 'ready page:load', ->
  $('textarea[class*=autosize]').autosize({append: "\n"});