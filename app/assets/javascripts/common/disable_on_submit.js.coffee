jQuery ($) ->
  $(document).on 'ajax:beforeSend', '[data-disable-on-submit]', (e) ->
    $(e.target).addClass('disabled')

  $(document).on 'ajax:beforeSend', 'form[data-disable-on-submit]', (e) ->
    $(e.target).find(':submit').addClass('disabled')
