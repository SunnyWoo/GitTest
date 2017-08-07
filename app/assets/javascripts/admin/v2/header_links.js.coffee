$(document).on 'page:change', ->
  jQuery ->
    $('form').on 'click', '.remove_fields', (event) ->
      $(this).prev('input[type=hidden]').val('1')
      $(this).closest('.tag_fields').hide()
      event.preventDefault()

    $('form').on 'click', '.add_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(this).data('id'), 'g')
      $('#tags_fields').append($(this).data('fields').replace(regexp, time))
      event.preventDefault()


    $('#header_link_link_type').change ->
      if $('#header_link_link_type').val() != "create"
        $('.header_link_spec_id').hide()
      else
        $('.header_link_spec_id').show()

    if $('#header_link_parent_id').val() == undefined || $('#header_link_parent_id').val() == ''
      $('.header_link_row').hide()

