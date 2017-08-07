class @CanvasPreview
  constructor: ->
    @canvas = null
    @model_name = $('#drawing').data('model-name')
    @model_w = $('#drawing').data('model-width')
    @model_h = $('#drawing').data('model-height')
    @backgroundColor = $('#drawing').data('modelBackgroundColor') or 'transparent'
    @backgroundColor = 'transparent' if @backgroundColor == 'none'
    @model_w_inner = null
    @model_h_inner = null
    @winh = $(window).height() - 161
    @canvas_x = null
    @canvas_y = null
    @zoom = 1

  outputToPreview: ->
    if @winh < @model_h
      @zoom = @winh / @model_h
      @model_h = @winh
      @model_w = @model_w * @zoom
    @canvas_x = @model_w / 2
    @canvas_y = @model_h / 2

    @canvas.discardActiveObject()
    cmdp.init_layer?.remove();
    @canvas.setOverlayImage '', @canvas.renderAll.bind(@canvas)
    @canvas.setBackgroundColor(@backgroundColor)
    @canvas.renderAll()
    @saveToLocalStorage('cover', @canvas.toDataURL())

    return

  saveToLocalStorage: (type, img_data)->
    # resize img_data
    img = new Image()
    img.src = img_data
    if img.complete # was cached
      resizeImg = @tmpCanvas(img, img_data)
      @redirectToPreview(type, resizeImg)
    else # wait for decoding
      img.onload = =>
        resizeImg = @tmpCanvas(img, img_data)
        @redirectToPreview(type, resizeImg)
        return

  redirectToPreview: (type, resizeImg) ->
    if typeof Storage isnt 'undefined'
      switch type
        when 'cover'
          console.log resizeImg
          localStorage.setItem('cmdp_editor_coverImage', resizeImg)
          localStorage.setItem('cmdp_editor_coverImage_width', @model_w_inner * @zoom)
          localStorage.setItem('cmdp_editor_coverImage_height', @model_h_inner * @zoom)
        else
          console.log 'Save Storage images error!'
      window.location.assign './preview'
    else
      alert 'Sorry! No Web Storage support..'

    return

  tmpCanvas: (elm, img_data)->
    canvas = document.createElement('canvas')
    if elm.height > 480
      height = 480
      width = elm.width * (480 / elm.height)
    else
      height = elm.height
      width = elm.width

    canvas.width = width
    canvas.height = height
    context = canvas.getContext('2d')

    context.drawImage(elm, 0, 0, width, height)
    canvas.toDataURL()
