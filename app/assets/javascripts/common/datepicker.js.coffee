#= require bootstrap-datepicker

jQuery ($) ->
  $(document).on 'ready page:load', ->
    $('[data-daterange]').datepicker(format: 'yyyy/mm/dd')

    $('.datepicker').datepicker
      format: 'yyyy-mm-dd'
      autoclose: true