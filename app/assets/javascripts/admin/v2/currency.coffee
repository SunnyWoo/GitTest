jQuery ($) ->
  $(document).on 'page:change',  ->
    $('[data-behavior~=currency-select]').on 'change', ->
      selected_option = $('[data-behavior~=currency-select] option:selected')
      $("input#currency_type_name").val(selected_option.text())
      $("input#currency_type_code").val(selected_option.val())