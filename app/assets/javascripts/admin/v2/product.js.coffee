$(document).on 'page:change', ->
  $('#product_model_export').on 'click',(e) ->
    checkeds = $('[name=product_model_id]:checked')
    ids = (c.value for c in checkeds)
    keys = ($(c).data('key') for c in checkeds)
    if ids.length == 0
      Gritter.error_msg('Error', 'Please select product model')
      return false

    if confirm("確定要 Export (#{keys})")
      Gritter.regular_msg('Processing', 'Please wait...')
      location.href = "#{$(this).attr('href')}.json?ids=#{ids}"
    else
      Gritter.regular_msg('Nothing', 'Ok bye~')

    return false

