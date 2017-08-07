@Sortable =
  start: (element) ->
    $(element).sortable
      update: (e, ui) ->
        $itme = ui.item
        url = $itme.data('url')
        page = $itme.data('page') - 1  or 0
        per_page = $itme.data('per-page')  or 0
        position = $itme.index() + (page * per_page) + 1
        $.ajax
          type: 'put'
          url: url
          data:
            position: position
        .done (e) ->
          if e.status == 'ok'
            Gritter.regular_msg e.message
          else
            Gritter.error_msg e.message
          Turbolinks.visit()

jQuery ($) ->
  $(document).on 'page:change',  ->
    Sortable.start('.sortable') if $('.sortable').length > 0
