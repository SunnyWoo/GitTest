$ ->
  $(document).on 'click', '#ready_all_invoice, #free_all_invoice', ->
    confirm_msg = ''
    confirm_msg = '確定 加入開立發票?' if this.id == 'ready_all_invoice'
    confirm_msg = '確定 免開發票?' if this.id == 'free_all_invoice'

    if confirm confirm_msg
      state = $(this).data('state')
      url = $(this).data('url')
      order_ids = []
      $("input.order[type=checkbox]:checked").each (i, e)->
        order_ids.push(e.value)

      $.ajax
        type: 'put'
        url: url
        data:
          ids: order_ids
          order:
            invoice_state: state
      .done (e) ->
        if e.ok
          Gritter.regular_msg e.ok.message
          $.each e.ok.ids, (i, id)->
            $(".order_tr[data-id=#{id}]").remove();
        if e.error
          $.each e.error, (i, msg)->
            Gritter.error_msg msg


  $(document).on 'click', '#ready_invoice, #free_invoice', ->
    confirm_msg = ''
    confirm_msg = '確定 加入開立發票?' if this.id == 'ready_invoice'
    confirm_msg = '確定 免開發票?' if this.id == 'free_invoice'

    if confirm confirm_msg
      id = $(this).data('id')
      state = $(this).data('state')
      url = $(this).data('url')
      data = order:
        invoice_state: state

      $.jsonPUT(url, data).done (e) ->
        if e.status == 'ok'
          Gritter.regular_msg e.message
          $(".order_tr[data-id=#{id}]").remove();
          location.reload() if !location.pathname.match('approve')
        else
          Gritter.error_msg e.message

  $(document).on 'submit', '.order_update_invoice_number', ->
    val = $("#order_invoice_number").val()
    if val != '' && !val.match(/^[a-z]{2}[0-9]{8}$/i)
      $.fancybox.hideLoading()
      Gritter.error_msg '發票號碼格式錯誤！'
      return false

    $this = $(this)
    $.ajax
      type: 'put'
      url: $this.attr("action")
      data: $this.serialize()
    .done (e) ->
      if e.status == 'ok'
        $(".order_tr[data-id=#{e.id}]").remove();
        Gritter.regular_msg e.message
      else
        Gritter.error_msg e.message
    return false


  $(document).on 'click', '#should_rate', ->
    for checkbox in $('[id*=q_shipping_info_country_code_in_]')
      $checkbox = $(checkbox)
      if $checkbox.val() == 'TW'
        $checkbox.attr('checked', 'checked')
      else
        $checkbox.removeAttr('checked')

  $(document).on 'click', '#not_should_rate', ->
    for checkbox in $('[id*=q_shipping_info_country_code_in_]')
      $checkbox = $(checkbox)
      if $checkbox.val() != 'TW'
        $checkbox.attr('checked', 'checked')
      else
        $checkbox.removeAttr('checked')

  $(document).on 'click', '#cancel_rate', ->
      for checkbox in $('[id*=q_shipping_info_country_code_in_]')
        $(checkbox).removeAttr('checked')
