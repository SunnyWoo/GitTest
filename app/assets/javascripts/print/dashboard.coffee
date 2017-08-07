@Dashboard =
  updateInvoice: (url, invoice_number) ->
    $.ajax
      url: url
      type: 'PUT'
      data:
        format: 'json'
        order: invoice_number: invoice_number
      success: (_result) ->
        Gritter.regular_msg '更新成功'

$(document).on 'ready page:change', ->
  $('.update_invoice_number').on 'click', (event) ->
    url = $(this).data('url')
    invoice_number = $(this).parents('td').find('input[name="print_ship_form[update_invoice_number]"]').val()
    Dashboard.updateInvoice(url, invoice_number)
    return false