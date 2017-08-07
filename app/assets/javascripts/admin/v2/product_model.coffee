$(document).on 'page:change', ->
  jQuery ->
    $('form').on 'click', '.remove_fields', (event) ->
      $(this).prev('input[type=hidden]').val('1')
      $(this).closest('.description_image_fields').hide()
      event.preventDefault()

    $('form').on 'click', '.add_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $('#description_images_fields').append($(this).data('fields').replace(regexp, time))
      event.preventDefault()
