class @SafeArea
  constructor: ->
    @canvas = null
    @groupAll = null
    @tmpObj = []
    @groupConfig =
      originX: 'center'
      originY: 'center'
      selectable: false

  groupAllObjects: ->
    objs = @canvas.getObjects().map((o) ->
      if cmdp.storage.objs[o.hash_key]?.prop is 'background_color'
        o.setScaleX(1)
        o.setScaleY(1)
      o.set 'active', true
    )
    group = new fabric.Group objs, @groupConfig
    @canvas.deactivateAll()
    @canvas.add group
    @canvas.renderAll()

    @canvas.fire 'selection:cleared'

    @groupAll = @canvas.item(_.size(objs))
    gTop = @groupAll.top - (@groupAll.height / 2)
    gBottom = @groupAll.top + (@groupAll.height / 2)
    gLeft = @groupAll.left - (@groupAll.width / 2)
    gRight = @groupAll.left + (@groupAll.width / 2)

    group._restoreObjectsState();
    @canvas.remove(group);
    @canvas.renderAll();

    return @checkArea(gTop, gBottom, gLeft, gRight)

  checkArea: (gTop, gBottom, gLeft, gRight)->
    if _isDebug
      console.log 'Safe area(gTop, gBottom, gLeft, gRight) >>', gTop, gBottom, gLeft, gRight
      console.log 'Model info(width, height) >>', _modal_w, _modal_h

    if gTop <= 0 and gLeft <= 0 and gBottom >= _modal_h and gRight >= _modal_w
      return true
    else
      return false
