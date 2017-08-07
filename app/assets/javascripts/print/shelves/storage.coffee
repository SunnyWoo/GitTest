@ShelfStorage =
  seeking_shelf: (serial) ->
    Shelf.seek(serial, (data) ->
      if data.shelf
        $('#shelf_name').val(data.shelf.category_name)
        $('#shelf_name').data('available', true)
      else
        $('#shelf_name').val('')
        $('#shelf_name').removeData('available')
    )

  seeking_material: (serial) ->
    ShelfMaterial.seek(serial, (data) ->
      if data.shelf_material
        $('#material_name').val(data.shelf_material.name)
        $('#material_name').data('available_quantity', data.shelf_material.available_quantity)
        $('#material_name').data('available', true)
      else
        $('#material_name').val('')
        $('#material_name').removeData('available_quantity')
        $('#material_name').removeData('available')
    )

  seeking_storage: (shelf_serial, material_serial) ->
    StorageShelf.seek(shelf_serial, material_serial, (data) ->
      if data.shelf
        $('#shelf_name').val(data.shelf.category_name)
        $('#shelf_name').data('available', true)
        $('#shelf_name').data('shelf_quantity', data.shelf.quantity)
        $('#material_name').val(data.shelf.material.name)
        $('#material_name').data('available_quantity', data.shelf.material.available_quantity)
        $('#material_name').data('available', true)
      else
        $('#shelf_name').val('')
        $('#shelf_name').removeData('available')
        $('#shelf_name').removeData('shelf_quantity')
        $('#material_name').val('')
        $('#material_name').removeData('available_quantity')
        $('#material_name').removeData('available')
    )

  checkStock: ->
    error = false
    msgs = []
    stock_quantity = parseInt($('#storage_quantity').val())
    material_available_quantity = parseInt(
      $('#material_name').data('available_quantity')
    )

    if !$('#shelf_name').data('available')
      error = true
      msgs.push '指定的貨架不存在'

    if !$('#material_name').data('available')
      error = true
      msgs.push '指定的物料不存在'

    if stock_quantity > material_available_quantity && $('#shelf_name').val() != '报废'
      error = true
      msgs.push "物料储备不足: 补货范围 0-#{material_available_quantity}"

    if error
      for mag in msgs
        Gritter.error_msg mag
      return false
    else
      return true

  checkChanging: ->
    error = false
    msgs = []
    input_quantity = parseInt($('#storage_quantity').val())
    material_available_quantity = parseInt(
      $('#material_name').data('available_quantity')
    )
    shelf_quantity = parseInt(
      $('#shelf_name').data('shelf_quantity')
    )
    changing_action = $('input[name="changing_action"]').val()

    if !$('#shelf_name').data('available')
      error = true
      msgs.push '指定的貨架不存在'

    if !$('#material_name').data('available')
      error = true
      msgs.push '指定的物料不存在'

    if input_quantity > shelf_quantity
      error = true
      msgs.push "數量不合法: 最大數量 #{shelf_quantity}"

    if error
      for mag in msgs
        Gritter.error_msg mag
      return false
    else
      return true

  addMoveFromFields: ->
    $('#add_move_from').click ->
      time = new Date().getTime()
      $('table tr.move_from:first').clone().find('input').each(->
        $(this).val('').attr 'name', (_, name) ->
          name.replace '[from]', '[' + time + ']'
        return
      ).end().appendTo 'table.move_from'

  addMoveTargetFields: ->
    $('#add_move_target').click ->
      time = new Date().getTime()
      $('table tr.move_target:first').clone().find('input').each(->
        $(this).val('').attr 'name', (_, name) ->
          name.replace '[target]', '[' + time + ']'
        return
      ).end().appendTo 'table.move_target'

  adjust: ->
    $('#storage_adjust').click ->
      shelf_serial = $('#shelf_serial').val()
      material_serial = $('#material_serial').val()
      quantity = $('#quantity').val()
      StorageShelf.seek(shelf_serial, material_serial, (data) ->
        if data.shelf
          $storageRecord = $("#storage_" + data.shelf.id + "_quantity")
          $storageRecord.val(quantity)
          $storageRecord.trigger 'change'
          $storageRecord.closest('tr').removeClass('hide')
        else
          Gritter.error_msg '该货架不存在'
          $("<tr><td>#{shelf_serial}</td><td>#{material_serial}</td><td>#{quantity}</td></tr>").appendTo(".error_shelf")
      )
      $('#shelf_serial').val('')
      $('#shelf_serial').focus()
      $('#material_serial').val('')
      $('#quantity').val('')

  finishAdjust: ->
    $('#finish_adjust').click ->
      $('.miss_shelf').empty()
      $('#adjusting_shelf tr.hide').each(->
        shelf_serial = $(this).find('.shelf_serial').text()
        material_serial = $(this).find('.material_serial').text()
        quantity = $(this).find('.original_quantity').text()
        $("<tr><td>#{shelf_serial}</td><td>#{material_serial}</td><td>#{quantity}</td></tr>").appendTo(".miss_shelf")
      )

  restore: ->
    $('#restore .serial').on 'change', (event) ->
      shelf_serial = $('#shelf_serial').val()
      material_serial = $('#material_serial').val()
      ShelfStorage.seeking_storage(shelf_serial, material_serial)

jQuery ->
  $('#shelf_storage #shelf_serial').on 'change', (event) ->
    shelf_serial = $(this).val()
    ShelfStorage.seeking_shelf(shelf_serial)

  $('#shelf_storage #material_serial').on 'change', (event) ->
    material_serial = $(this).val()
    ShelfStorage.seeking_material(material_serial)

  $('#shelf_storage').on 'click', 'input[type="submit"]', (event) ->
    return ShelfStorage.checkStock()

  $('#changing_storage #shelf_serial').on 'change', (event) ->
    shelf_serial = $('#shelf_serial').val()
    material_serial = $('#material_serial').val()
    ShelfStorage.seeking_storage(shelf_serial, material_serial)

  $('#changing_storage #material_serial').on 'change', (event) ->
    shelf_serial = $('#shelf_serial').val()
    material_serial = $('#material_serial').val()
    ShelfStorage.seeking_storage(shelf_serial, material_serial)

  $('#changing_storage').on 'click', 'input[type="submit"]', (event) ->
    return ShelfStorage.checkChanging()

  $('tr input').on 'change', (event) ->
    original_quantity = parseInt $(this).parents('tr').find('.original_quantity').text()
    adjust_quantity = parseInt $(this).val()
    result = adjust_quantity - original_quantity
    $(this).parents('tr').find('.result').text(result)
    sum_result = 0
    $('.result').each (i, item ) ->
      sum_result += parseInt $(item).text()
    $('#sum_result').text(sum_result)

  ShelfStorage.addMoveFromFields()
  ShelfStorage.addMoveTargetFields()
  ShelfStorage.adjust()
  ShelfStorage.finishAdjust()
  ShelfStorage.restore()