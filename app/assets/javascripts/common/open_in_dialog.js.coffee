# 加上 data-open-in-dialog
jQuery ($) ->
  $(document).on 'click', 'a[data-open-in-dialog]', (e) ->
    e.preventDefault()
    $this = $(e.target)
    window.open $this.attr('href'), '_blank', 'width=800,height=600'
