$(document).on 'page:change', ->
  $('#export_type').on 'change',(event) ->
    if $(this).val() == 'time'
      $('#time_export_type').removeClass('hide')
    else
      $('#time_export_type').addClass('hide')
