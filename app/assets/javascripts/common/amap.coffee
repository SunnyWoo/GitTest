@ChinaAmap =
  render_map: (map_id) ->
    return false if !AMap?

    map = new (AMap.Map)(map_id, {resizeEnable: true, zoom: 14})

    map.plugin ["AMap.ToolBar"], () ->
      toolBar = new (AMap.ToolBar)({direction:false})
      toolBar.hideLocation()
      map.addControl(toolBar)

    AMap.service ["AMap.Geocoder"], () ->
      address = $('#shipping_address').val()
      myGeo = new (AMap.Geocoder)({radius: 500})
      myGeo.getLocation address, ((status, result) ->
        if status == 'complete' && result.info == 'OK'
          infoWindow = new (AMap.InfoWindow)(content: address, autoMove: true, offset:{x:0,y:-30})
          location = result.geocodes[0].location
          position = new (AMap.LngLat)(location.getLng(), location.getLat())
          mar = new (AMap.Marker)(map: map, position: position)
          infoWindow.open(map, mar.getPosition())
          map.setFitView()
        else
          $("##{map_id}").html '您选择地址没有解析到结果!'
      ), $('#shipping_city').val()
      return

$(document).on 'page:change',  ->
  if $("#amap").length > 0
    ChinaAmap.render_map('amap')
