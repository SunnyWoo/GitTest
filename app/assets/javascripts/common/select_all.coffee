$(document).on 'ready page:load', ->
  $(document).on 'click', '[data-select-all]', (e)->
    $this = $(this)
    select_all = $this.data('select-all')
    column = $this.data('column')
    $("[name*=#{column}]").prop('checked', select_all)
    e.preventDefault()
