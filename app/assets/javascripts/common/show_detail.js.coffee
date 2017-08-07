jQuery ($) ->
  $(document).on 'click', '[data-show-detail]', (e) ->
    e.preventDefault()
    $this = $(e.target)
    $($this.data('showDetail')).removeClass('hide').fadeIn()
    $this.remove()
