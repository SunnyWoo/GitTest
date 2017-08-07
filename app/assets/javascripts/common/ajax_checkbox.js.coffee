jQuery ($) ->
  $(document).on 'change', ':checkbox', (e) ->
    $this = $(e.target)
    url = if $this.prop('checked')
            $this.data('checkboxCheckUrl')
          else
            $this.data('checkboxUncheckUrl')
    $.ajax(type: 'PATCH', url: url) if url

