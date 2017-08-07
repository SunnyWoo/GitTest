jQuery ($) ->
  $(document).on 'page:change',  ->
    $('[data-rel=popover]').popover({container:'body'})