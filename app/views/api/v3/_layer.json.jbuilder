cache_json_for json, layer do
  builtin = %w(shape sticker typography line texture frame).include? layer.layer_type
  resource = CommandP::Resources.send(layer.layer_type.pluralize)[layer.material_name] if builtin

  json.call(layer, :id, :uuid, :layer_type, :position_x, :position_y,
            :orientation, :scale_x, :scale_y, :transparent, :color,
            :material_name, :font_name, :font_text, :text_alignment,
            :text_spacing_x, :text_spacing_y)
  json.image do
    if builtin
      json.normal image_url(resource.file)
    else
      json.normal layer.image.url
      json.md5sum layer.image.md5sum
    end
  end
  json.filter layer.filter
  json.filtered_image do
    if builtin
      json.normal image_url(resource.file)
    else
      json.normal layer.filtered_image.url
      json.md5sum layer.filtered_image.md5sum
    end
  end
  json.position layer.position
  json.masked layer.mask.present?
  json.masked_layers do
    json.partial! 'api/v3/masked_layer', collection: layer.masked_layers, as: :layer
  end
end
