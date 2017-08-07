$(document).on 'ready page:change', ->
  $('#batch_flow_factory_id').on 'change', (select) ->
    locale = $('#batch_flow_factory_id option:selected').data('locale')
    console.log locale
    $('#batch_flow_locale').val(locale)
