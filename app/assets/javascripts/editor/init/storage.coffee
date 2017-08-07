# TODO: 精簡 storage

class @CanvaStorage
  constructor: ->
    @objs = {}
    @canvas_x = 0
    @canvas_y = 0

  addObjs: (prop, data, data_name, e, canvas_x, canvas_y, key=undefined) =>
    @canvas_x = canvas_x
    @canvas_y = canvas_y
    properties = {}
    if key is undefined
      properties.hash_key = e.hash_key
    else
      properties.hash_key = key
    properties.prop = prop
    properties.data = data
    properties.material_name = data_name
    properties.width = e.width
    properties.height = e.height

    if e.getFlipX() is false
      properties.scaleX = e.getScaleX() / _zoom
    else
      properties.scaleX = ( e.getScaleX() * -1 ) / _zoom

    if e.getFlipY() is false
      properties.scaleY = e.getScaleY() / _zoom
    else
      properties.scaleY = ( e.getScaleY() * -1 ) / _zoom

    switch prop
      when 'photo'
        properties.scaleX = properties.scaleX / 2
        properties.scaleY = properties.scaleY / 2
        properties.color = ''
        # console.log 'storage uuid >>', e.hash_key
        # console.log 'storage obj_zoom >>', properties.scaleX
      when 'text'
        properties.scaleX = properties.scaleX * _zoom
        properties.scaleY = properties.scaleY * _zoom
        properties.color = e.getFill()
      when 'background_color'
        properties.color = data
      else
        properties.color = e.fillColor
        
    properties.angle = e.getAngle()
    properties.left = (e.getLeft() - canvas_x) / _zoom
    properties.top = (e.getTop() - canvas_y) / _zoom
    properties.opacity = e.getOpacity()
    properties.layer = _.size(@objs) + 1
    properties.original_scale = e.original_scale
    properties.text = e.text or null
    properties.text_align = 'left'
    properties.text_spacing_x = 0
    properties.text_spacing_y = 0
    if prop is 'text'
      properties.font_name = data
    else
      properties.font_name = null
    @objs[e.hash_key] = properties
    return

  setObjs: (e) =>
    # console.log 'update...', e, e.hash_key
    @objs[e.hash_key].width = e.width
    @objs[e.hash_key].height = e.height
    prop = @objs[e.hash_key].prop

    if e.getFlipX() is false
      @objs[e.hash_key].scaleX = e.getScaleX() / _zoom
    else
      @objs[e.hash_key].scaleX = ( e.getScaleX() * -1 ) / _zoom
    if e.getFlipY() is false
      @objs[e.hash_key].scaleY = e.getScaleY() / _zoom
    else
      @objs[e.hash_key].scaleY = ( e.getScaleY() * -1 ) / _zoom

    switch prop
      when 'photo'
        @objs[e.hash_key].scaleX = @objs[e.hash_key].scaleX / 2
        @objs[e.hash_key].scaleY = @objs[e.hash_key].scaleY / 2
        # console.log '............storage setObjs'
        # console.log 'storage set obj_zoom >>', @objs[e.hash_key].scaleX, e.getScaleX()
      when 'text'
        @objs[e.hash_key].scaleX = @objs[e.hash_key].scaleX * _zoom
        @objs[e.hash_key].scaleY = @objs[e.hash_key].scaleY * _zoom
      when 'background_color'
        @objs[e.hash_key].scaleX = 1
        @objs[e.hash_key].scaleY = 1

    @objs[e.hash_key].angle = e.getAngle()
    @objs[e.hash_key].left = (e.getLeft() - @canvas_x) / _zoom
    @objs[e.hash_key].top = (e.getTop() - @canvas_y) / _zoom
    @objs[e.hash_key].opacity = e.getOpacity()
    # @objs[e.hash_key].color = e.getFill()
    # @objs[e.hash_key].layer = e.layer
    return

  setText: (e) =>
    @objs[e.hash_key].text = e.text
    @objs[e.hash_key].text_align = e.getTextAlign()
    @objs[e.hash_key].font_name = e.getFontFamily()
    return

  setObjColor: (e, color) =>
    @objs[e.hash_key].color = color
    return

  setLayer: (key, layer) =>
    @objs[key].layer = layer
    return

  removeObjs: (key) =>
    delete @objs[key]
    return

  getObjs: (key=null) =>
    if key isnt null
      @objs[key]
    else
      @objs

  toObjectData: (key) =>
    obj = new Object()
    if typeof @objs[key] isnt 'undefined'
      obj.key = key
      obj.material_name = @objs[key].material_name
      obj.scaleX = Math.round(@objs[key].scaleX * 100000) / 100000
      obj.scaleY = Math.round(@objs[key].scaleY * 100000) / 100000
      obj.angle = Math.round(parseFloat(@objs[key].angle, 10) * 100) / 100
      obj.left = Math.round(@objs[key].left * 100000) / 100000
      obj.top = Math.round(@objs[key].top * 100000) / 100000
      obj.opacity = Math.round(parseFloat(@objs[key].opacity, 10) * 100) / 100
      obj.position = @objs[key].layer
      obj.prop = @objs[key].prop
    else
      obj.key = key
      obj.error = true
    return obj
