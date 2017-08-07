jQuery ($) ->
  $(document).on 'ready page:load', ->
    if $('#change_price_type')
      $('#change_price_type').on 'change', () ->
        $.ajax
          type: 'get'
          url: $(this).data('url')
          data:
            target_type: $(this).val()
