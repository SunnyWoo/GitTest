#= require editable/bootstrap-editable
#= require editable/rails

jQuery ($) ->
  $(document).on 'page:change',  ->
    $('.editable').editable
      success: (response, newValue) ->
        states = ['pending', 'canceled']
        if states.indexOf(newValue) > -1
          $('a[href=#resend_receipt]').addClass('hide')
        else
          $('a[href=#resend_receipt]').removeClass('hide')
