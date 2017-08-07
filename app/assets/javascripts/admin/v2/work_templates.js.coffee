$(document).on 'page:change', ->
  $('form').on 'click', '.remove_mask_fields', (event) ->
    $(this).closest('tr').remove()
    event.preventDefault()

  $('form').on 'click', '.add_mask_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $("tbody").append($(this).data('fields').replace(regexp, time))
    event.preventDefault()