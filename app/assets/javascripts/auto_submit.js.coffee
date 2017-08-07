jQuery ($) ->
  $(document).on 'ready page:load', ->
    $('[data-auto-submit]').submit()
