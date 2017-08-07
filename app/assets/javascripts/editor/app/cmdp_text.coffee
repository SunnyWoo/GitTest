# Public: Render input text on Canvas.
#
# text          - input text
# canvas        - fabric's canvas object
# storage       - cmdp.storage object
# settings      - cmdp.settings object
# params
#   fontFamily  - font famlily
#   prop        - 'text'
#   uuid        - uuid
#   reRender    - true or false
#   position    - current position
#   color       - current color
#   top         - current value of y
#   left        - current value of x
#   opacity     - current opacity
#   angle       - current angle
#   flip_x      - true or false
#   flip_y      - true or false
#   zoom        - current text's zoom
#   alignment   - current alignment
#

window.cmdp ||= {}

class cmdp.Text
  constructor: (text, canvas, storage, settings, params) ->
    @text = if text then text else 'Hello!'
    @canvas = canvas
    @storage = storage
    @params = params
    @uiConfig = settings.uiConfig
    @ctrConfig = settings.ctrConfig
    @default = settings.default

  render: ->
    objZoom   = if @params.zoom then @params.zoom else 5
    flipX     = if @params.flipX then @params.flipX else false
    flipY     = if @params.flipY then @params.flipY else false
    opacity   = if @params.opacity then @params.opacity else 1
    angle     = if @params.angle then @params.angle else 0
    alignment = if @params.alignment then @params.alignment else 'left'
    top       = if @params.reRender then @params.top else @default.top
    left      = if @params.reRender then @params.left else @default.left

    textObj = new fabric.Text @text,
      fontFamily: @fixedFontName(@params.fontFamily)
      fontSize:   20
      fill:       if @params.color then @params.color else '#000000'
      originX:    'center'
      originY:    'center'
      scaleX:     objZoom
      scaleY:     objZoom
      flipX:      flipX
      flipY:      flipY
      lineHeight: 1.15
      top:        top
      left:       left
      opacity:    opacity
      angle:      angle
      textAlign:  alignment

    textObj.set @uiConfig
    textObj.setControlsVisibility @ctrConfig

    if @params.uuid is false
      tmpKey = @makeHashKey()
    else
      tmpKey = @params.uuid

    textObj.hash_key       = tmpKey
    textObj.layer          = @params.position
    textObj.original_scale = 5

    fontName = if @params.fontFamily then @params.fontFamily else $('.font-current').text()
    @storage.addObjs(@params.prop, fontName, null, textObj, @default.left, @default.top)
    @canvas.add textObj
    setTimeout( =>
      @canvas.renderAll()
      return
    , 100)
    @canvas.setActiveObject textObj
    tmpKey

  fixedFontName: (font) ->
    if font is 'Lobster1.4'
      newFont = 'Lobster14'
    else
      newFont = font

  makeHashKey: ->
    d = new Date().getTime()
    key = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, (c) ->
      r = (d + Math.random() * 16) % 16 | 0
      d = Math.floor(d / 16)
      ((if c is "x" then r else (r & 0x7 | 0x8))).toString 16)
    key

  getText: ->
    console.log 'Canvas >>', @canvas
    console.log '--->', @text


# ====== 以下為文字編輯相關 UI 行為 ======

$(document).on 'ready page:load', ->

  # 全形字體轉半形
  $("#input-text").blur ->
    value = $(this).val()
    result = ""
    i = 0
    while i < value.length
      if value.charCodeAt(i) is 12288
        result += " "
      else
        if value.charCodeAt(i) > 65280 and value.charCodeAt(i) < 65375
          result += String.fromCharCode(value.charCodeAt(i) - 65248)
        else
          result += String.fromCharCode(value.charCodeAt(i))
      i++
    $(this).val result
    return

  # 更新文字
  $('#update-text').on 'click', ->
    activeObj = cmdp.getActiveObj()
    text = $('#input-text').val()
    activeObj.setText(text).setCoords()
    cmdp.storage.setText(activeObj)
    cmdp.c.renderAll()
    cmdp.c.fire 'object:modified', activeObj
    return

  # 更新字體
  $('.font_sample').on 'click', ->
    activeObj = cmdp.getActiveObj()
    fontName = $(this).text()
    fontClass = $(this).attr('data-lib')
    if fontName is 'Lobster1.4'
      activeObj.setFontFamily('Lobster14').setCoords()
    else
      activeObj.setFontFamily(fontName).setCoords()
    cmdp.storage.setText(activeObj)
    cmdp.c.renderAll()

    $('.font-current')
      .text(fontName)
      .removeClass()
      .addClass('font-current ' + fontClass)
      .attr('data-class-name', fontClass)
    $('#setObj').mCustomScrollbar('scrollTo', 'top')

    cmdp.c.fire 'object:modified', activeObj
    return

  # 更新字體向左對齊
  $('.text-align-left').on 'click', ->
    activeObj = cmdp.getActiveObj()
    activeObj.setTextAlign('left')
    cmdp.storage.setText(activeObj)
    cmdp.c.renderAll()
    cmdp.c.fire 'object:modified', activeObj
    return

  # 更新字體置中對齊
  $('.text-align-center').on 'click', ->
    activeObj = cmdp.getActiveObj()
    activeObj.setTextAlign('center')
    cmdp.storage.setText(activeObj)
    cmdp.c.renderAll()
    cmdp.c.fire 'object:modified', activeObj
    return

  # 更新字體向右對齊
  $('.text-align-right').on 'click', ->
    activeObj = cmdp.getActiveObj()
    activeObj.setTextAlign('right')
    cmdp.storage.setText(activeObj)
    cmdp.c.renderAll()
    cmdp.c.fire 'object:modified', activeObj
    return

  return
