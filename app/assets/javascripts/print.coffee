#= require jquery
#= require jquery_ujs
#= require plugins/jquery-ui-1.10.3.custom.min
#= require plugins/jquery.ui.touch-punch.min
#= require plugins/jquery.autosize-min
#= require plugins/jquery.validate.min
#= require plugins/bootstrap.min
#= require plugins/excanvas.min
#= require print/ace.min
#= require print/ace-elements.min
#= require jquery-ui/datepicker
#= require jquery-ui/datepicker-zh-TW
#= require rails_env_favicon
#= require print/jquery.gritter.min
#= require print/bootbox.min
#= require print/uploading
#= require print/fancybox
#= require print/imposition_editor
#= require print/vanaheim_labels
#= require print/jquery-barcode.min
#= require common/disable_on_submit
#= require print/picking_materials
#= require print/shelves/shelves
#= require print/shelves/shelf_materials
#= require common/datetimepicker
#= require common/datepicker
#= require print/imposition_demo
#= require print/shelves/storage
#= require print/dashboard
#= require print/batch_flow

@Poller =
  poll: (url, product_model_id) ->
    window.timeout_id = setTimeout (->
      Poller.request(url, product_model_id)
    ), 5000
  request: (url, product_model_id) ->
    last_id = $("#model-" + product_model_id + "-section tr").first().data('id')
    if last_id > 0
      tag = "model_id:#{product_model_id} , last_id:#{last_id}"
      console.time(tag)
      $.ajax
        url: url
        type: 'get'
        data:
          product_model_id: product_model_id
          last_id: last_id
      .done (response) ->
        console.timeEnd(tag)
      .fail (response) ->
        console.timeEnd(tag)

    else
      Poller.finsih()
  finsih: () ->
    Gritter.regular_msg '上傳完成！'
    window.timeout_id = 0
    $('[id*=print_action]input:not(:checked)').removeAttr('disabled')
    $('[id*=print_action]input:checked').removeAttr('checked')

@CheckBox =
  check_all: ->
    $('table th input:checkbox').on 'click' , ->
        that = this;
        $(this).closest('table').find('tr > td:first-child input:checkbox').each ->
            this.checked = that.checked
            $(this).closest('tr').toggleClass('selected')

@Sublimate =
  check_submit: ->
    model_id = $("#current_model").data('model_id')
    checked_count = $('[name*=order_item]:checked').length
    Gritter.error_msg("警告！","請先選擇要完成的項目。") if checked_count == 0

    tmp_model = $('[name*=order_item]:checked')[0].getAttribute('data-model')
    tmp_order_item_id = []

    for checkbox in $('[name*=order_item]:checked')
      return Gritter.error_msg("警告！","多選的處理項目，包含不同的「產品類型」，請在確認！") if tmp_model != $(checkbox).data('model')
      tmp_order_item_id.push checkbox.value
      $(checkbox).parents('tr').fadeOut( "slow")

    update_count = parseInt($(".badge.badge-danger[data-behavior*='2']:first").html()) - checked_count
    $(".badge.badge-danger[data-behavior*='2']").html(update_count)

    $.ajax
      url : "/print/order_items/#{tmp_order_item_id.join(',')}/sublimate.json"
      type : 'PATCH'
      contentType : 'application/json'

    Gritter.regular_msg "完成送出！"

@Gritter =
  error_msg: (title, text = null) ->
    param =
      title: title
      class_name: 'gritter-error'
    param.text = text if text
    $.gritter.add param

  # class_name :
  #  for color:  gritter-light gritter-info gritter-success gritter-warning
  #  is_center:  gritter-center
  regular_msg: (title, text, image = null, sticky = false, time = '', class_name = 'gritter-light') ->
    param =
      title: title
      sticky: sticky
      time: time
      class_name: class_name
    param.image if image
    param.text if text
    $.gritter.add param

  remove_all: ->
    $.gritter.removeAll()

$(document).ready ->
  App.init()

window.App =
  init : () ->
    window.timeout_id = 0
    $('[data-behavior~=polling-trigger]').on 'click', ->
      product_model_id = $(this).data('product-model-id')
      product_model_item_count = $("[data-behavior=model-#{product_model_id}-items-count]").html()

      if product_model_item_count == "0"
        Gritter.error_msg("警告！","等待上傳的數量為 ０ , 無法開啟上傳。")
        return false

      print_action = $(this).data("action")
      if print_action == 0
        $(this).data('action', 1)
        $('[id*=print_action]input:not(:checked)').attr('disabled',true)
        Poller.poll($(this).data('update-url'), $(this).data('product-model-id'))

      else if print_action == 1
        $('[id*=print_action]input:not(:checked)').removeAttr('disabled')
        $(this).data('action', 0)
        clearTimeout window.timeout_id
        window.timeout_id = 0

    if $('[data-page~=dashboard_index]').length > 0
      $(window).on 'beforeunload', (e) ->
        '離開頁面將會暫停列印！' if window.timeout_id > 0

    if $('.ftp_service_status').length > 0
      if $('.ftp_service_status').data('val') != 200
        $('a').attr('disabled',true)

    # barcode of print_item.timestamp_no
    if $('#barcode').length > 0
      $('#barcode').barcode($('#timestamp_no').val(), 'code128')

    # barcode of order.order_no
    if $('#order_no_barcode').length > 0
      $('#order_no_barcode').barcode($('#order_no').val(), 'code128').css({'width': 'auto', 'margin-left': '-5px'})
      if $('#deliver_order_no_barcode').length > 0
        $('#deliver_order_no_barcode').barcode($('#deliver_order_no').val(), 'code128').css({'width': 'auto', 'margin-left': '-5px'})
      window.print()

    # sublimate page
    CheckBox.check_all()

    $('#sublimate_check_submit').on 'click', ->
      Sublimate.check_submit()

    # ship
    $('.ship_code').on 'change', ->
      if $.trim($(this).val()) != ''
        $(".ship_submit", $(this).parent(".ship_form")).removeClass('disabled')
      else
        $(".ship_submit", $(this).parent(".ship_form")).addClass('disabled')

    # submit search_shelf_activities form
    $('.submit_shelf_activities_form').on 'click', ->
      $('form#search_shelf_activities').attr('action', $(this).data().url)
      $('form#search_shelf_activities').submit()

    $('.ship_form').submit (e)->
      currentForm = this
      e.preventDefault()
      bootbox.confirm "確認完成？", (res) ->
        if res
          currentForm.submit()
    $('#select_factory').on 'change', ->
      location.href = "#{location.pathname}?model_id=#{this.value}"

    $('.submit_shelf_material_activities_form').on 'click', ->
      $('form#search_shelf_materials_activities').attr('action', $(this).data().url)
      $('form#search_shelf_materials_activities').submit()
    $('.btn-danger.reprint').on 'click', ->
      $('#reprint_form_' + $(this).data().printItemId).modal('show')

    $('a.disable_schedule').on 'click', ->
      $(this).html('隱藏中...').on 'click', ->
        return false
