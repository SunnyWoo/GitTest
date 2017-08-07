$(document).ready ->
  # Color Picker
  $(".color-picker").spectrum
    showInitial: true
    showButtons: true
    color: '#000000'
    appendTo: '#color'
    chooseText: '<i class="edittools-check"></i>'
    change: (color) ->
      # console.log 'change -->', color.toHexString()
      cmdp.setColor(color.toHexString())
      setTimeout( ->
        cmdp.setColor(color.toHexString())
        return
      ,10)
      return
  
  # 水平鏡射
  $('.flip-x').on 'click', ->
    cmdp.setFlipX()
    return

  # 垂直鏡射
  $('.flip-y').on 'click', ->
    cmdp.setFlipY()
    return

  $('.center-v').on 'click', ->
    cmdp.setAlignmentV()

  $('.center-h').on 'click', ->
    cmdp.setAlignmentH()

  # 顯示 font list
  $('.font-current').on 'click', ->
    if ($('.font-lists').is(":visible"))
      $('.font-lists').hide()
    else
      $('.font-lists').show()
    return

  # 隱藏 font list
  $(document).mouseup (e) ->
    container = $('.font-current')
    if not container.is(e.target) and container.has(e.target).length is 0
      $('.font-lists').hide()
    return

  # 預覽按鈕
  $('.editor-btn-preview').on 'click', ->
    beforeRenderCover()
    return

  # 確認預覽
  $('#safe_confirmed').on 'click', ->
    cmdp.outputToPreview(true)
    return

  # 刪除按鈕
  $('.delete-obj').on 'click', ->
    $('#confirm_notice').modal('show')
    return

  # 確認刪除 
  $('#del_confirmed').on 'click', ->
    cmdp.removeObj()
    return