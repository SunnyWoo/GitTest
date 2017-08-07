@ShelfMaterial =
  seek: (serial, callback) ->
    queries = { serial: serial }
    $.getJSON('/print/shelf_materials/seek', queries).success (data) ->
      callback(data)

  seeking_material_name: (serial) ->
    ShelfMaterial.seek(serial, (data) ->
      if data.shelf_material
        $('input[name="shelf_material[name]"]').val(data.shelf_material.name)
      else
        $('input[name="shelf_material[name]"]').val('')
    )

jQuery ->
  $('#material_form').on 'change', 'input[data-find-material]', (event) ->
    serial = $('input[name="shelf_material[serial]"]').val()
    ShelfMaterial.seeking_material_name(serial)
    event.preventDefault()
