@GoogleMap =
  render_map: () ->
    geocoder = new google.maps.Geocoder()
    mapOptions =
      zoom: 14
    order_map_canvas = $("#order_map_canvas")
    map = new google.maps.Map(document.getElementById('order_map_canvas'), mapOptions)
    geocoder.geocode
      address: order_map_canvas.data('address')
    , (results, status) ->
      if status is google.maps.GeocoderStatus.OK
        map.setCenter results[0].geometry.location
        marker = new google.maps.Marker(
          map: map
          position: results[0].geometry.location
        )
      else
        console.log "Geocode was not successful for the following reason: " + status
      return

    return
    google.maps.event.addDomListener window, "load", initialize


$(document).on 'page:change',  ->
  if $("#order_map_canvas").length > 0
    GoogleMap.render_map()