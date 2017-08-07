jQuery ($) ->
  $(document).on 'ready page:load', ->
    $('.preview-composer-sorter tbody').sortable(
      handle: '.preview-composer-sorter-handle'
      update: (e, ui) ->
        url = ui.item.data('url')
        position = ui.item.index() + 1
        $.ajax(
          type: 'patch'
          url: url
          dataType: 'json'
          data: { preview_composer: { position: position } }
        )
    )
