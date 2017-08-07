#= require plugins/jquery.inputlimiter.1.3.1.min.js

$(document).on 'ready page:load', ->
  $('textarea.limited').inputlimiter({
      remText: '%n character%s remaining...',
      limitText: 'max allowed : %n.'
    });