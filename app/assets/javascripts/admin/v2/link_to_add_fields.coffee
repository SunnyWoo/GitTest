$(document).on 'page:change', ->
  jQuery ->
    $('form').on 'click', '.remove_fields', (event) ->
      closest = $(this).data('closest')
      $(this).prev('input[type=hidden]').val('1')
      $(this).closest(closest).hide()
      event.preventDefault()

    $('form').on 'click', '.add_fields', (event) ->
      target = $(this).data('target')
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $(target).append($(this).data('fields').replace(regexp, time))
      event.preventDefault()
