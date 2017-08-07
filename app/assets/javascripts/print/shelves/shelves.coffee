@Shelf =
  seek: (serial, callback) ->
    queries = { serial: serial }
    $.getJSON('/print/shelves/seek', queries).success (data) ->
      callback(data)

@StorageShelf =
  seek: (shelf_serial, material_serial, callback) ->
    queries = { shelf_serial: shelf_serial, material_serial: material_serial }
    $.getJSON('/print/shelves/seek', queries).success (data) ->
      callback(data)