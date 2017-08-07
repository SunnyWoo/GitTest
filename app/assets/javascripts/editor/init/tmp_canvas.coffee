# Public: Render text image for print image.
# 
# text          - input text
# settings
#   fontFamily  - font famlily
#   color       - text color
#   scaleY      - text scale y
#   scaleX      - text scale x
#   opacity     - text opacity
# 

# TODO: text to image
class @TmpCanvas
  constructor: ->
    @tmpCanvas = {}
    @defaultZoom = _zoom

  init: ->
    @tmpCanvas = new fabric.Canvas('tmp_png')
    @tmpCanvas.setBackgroundColor('transparent', @tmpCanvas.renderAll.bind(@tmpCanvas))
    @tmpCanvas.setHeight(_model_h_original)
    @tmpCanvas.setWidth(_model_w_original)
    return

  renderTextImage: (text, settings)->
    tmpText = new fabric.Text text,
      fontFamily: @fixedFontName(settings.fontFamily)
      fontSize:   20
      fill:       settings.color
      originX:    'center'
      originY:    'center'
      scaleX:     settings.scaleX / @defaultZoom
      scaleY:     settings.scaleY / @defaultZoom
      lineHeight: 1.15
      top:        0
      left:       0
      opacity:    settings.opacity
      angle:      0

    textBox = new fabric.Rect
      width: parseFloat(tmpText.getWidth()) * 1.3
      height: parseFloat(tmpText.getHeight()) * 1.3
      originX: 'center'
      originY: 'center'
      top:     0
      left:    0
      opacity: 0

    group = new fabric.Group [textBox, tmpText],
      originX: 'center'
      originY: 'center'
      top:     0
      left:    0

    @tmpCanvas.add group
    setTimeout( =>
      @tmpCanvas.renderAll()
      return
    , 100)

    group.toDataURL()

  fixedFontName: (font) ->
    if font is 'Lobster1.4'
      newFont = 'Lobster14'
    else
      newFont = font

  getCanvas: ->
    @tmpCanvas

  clearAll: ->
    @tmpCanvas.clear()

window.tmpDraw = new TmpCanvas()
tmpDraw.init()