jQuery ($) ->
  $(document).on 'page:change',  ->
    $('[data-rel=tooltip]').tooltip({container:'body'})