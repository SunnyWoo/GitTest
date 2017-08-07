@FormTimeout =
  init: (millisecond, redirect_to) ->
    setTimeout ->
      window.location.href = redirect_to
    , millisecond

jQuery ($) ->
  $(document).on 'submit', '[data-form-timeout]', (e) ->
    millisecond = $(this).data('millisecond')
    redirect_to = $(this).data('redirect-to')
    if millisecond && redirect_to
      FormTimeout.init(millisecond, redirect_to)