@beforeRenderCover = ->
  path = $('#drawing').data('layersPath')
  work_id = $('#drawing').data('work_id')
  hasDiff = null

  $.ajax(
      url: path
      type: 'GET'
      cache: false
      data: work_id
    ).done((response) =>
      _.forEach response.layers, (data) =>
        objServer = new Object()
        objLocal = cmdp.storage.toObjectData(data.uuid)
        objServer.key = data.uuid
        objServer.material_name = data.material_name
        objServer.scaleX = Math.round(data.scale_x * 100000) / 100000
        objServer.scaleY = Math.round(data.scale_y * 100000) / 100000
        objServer.angle = Math.round(parseFloat(data.orientation, 10) * 100) / 100
        objServer.left = Math.round(data.position_x * 100000) / 100000
        objServer.top = Math.round(data.position_y * 100000) / 100000
        objServer.opacity = Math.round(parseFloat(data.transparent, 10) * 100) / 100
        objServer.position = data.position
        objServer.prop = @getLayerType(data.layer_type)
        
        if objLocal.error is true
          url = path + '/' + data.uuid
          $.ajax(
            url: url
            type: 'DELETE'
          ).done((response) =>
            if _isDebug
              console.log 'Data Saved: ', response
            return
          ).fail((response) =>
            console.log 'Error: ', response.responseText
            return
          )
        else
          hasDiff = @getChanges(objLocal, objServer)
          if (_.size hasDiff) > 0
            if _isDebug
              console.log 'hasDiff >>', hasDiff
            @syncLayerData(objLocal)

        return
      
      if _isDebug
        console.log 'Data Saved: ', response

      cmdp.outputToPreview()
      return
    ).fail((response) ->
      console.log 'Error: ', response.responseText
      return
    )

  return

@getLayerType = (id) ->
  layer_type = [ 'camera'
                , 'photo'
                , 'background_color'
                , 'shape'
                , 'crop'
                , 'line'
                , 'sticker'
                , 'texture'
                , 'typography'
                , 'text'
                , 'lens_flare'
                , 'spot_casting'
                , 'spot_casting_text' ]
  return layer_type[id]

@syncLayerData = (hasDiff) ->
  path = $('#drawing').data('layersPath')
  url = path + '/' + hasDiff.key

  if hasDiff.prop is 'text'
    text_zoom = _text_zoom
  else
    text_zoom = 1

  data =
    'position': cmdp.storage.objs[hasDiff.key].layer
    'scale_x': cmdp.storage.objs[hasDiff.key].scaleX * text_zoom
    'scale_y': cmdp.storage.objs[hasDiff.key].scaleY * text_zoom
    'position_x': cmdp.storage.objs[hasDiff.key].left
    'position_y': cmdp.storage.objs[hasDiff.key].top
    'orientation': cmdp.storage.objs[hasDiff.key].angle

  $.ajax(
      url: url
      type: 'PATCH'
      data: data
    ).done((response) ->
      if _isDebug
        console.log 'Data Saved: ', response
      return
    ).fail((response) ->
      console.log 'Error: ', response.responseText
      return
    )
  return

@getChanges = (objLocal, objServer) ->
  changes = {}
  for prop of objServer
    if not objLocal or objLocal[prop] isnt objServer[prop]
      if typeof objServer[prop] is "object"
        c = getChanges(objLocal[prop], objServer[prop])
        # underscore
        changes[prop] = c  unless _.isEmpty(c)
      else
        changes[prop] = objServer[prop]
  changes