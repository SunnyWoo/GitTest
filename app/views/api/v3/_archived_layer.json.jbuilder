cache_json_for json, layer do
  json.call(layer, :id, :layer_type, :position_x, :position_y,
            :orientation, :scale_x, :scale_y, :transparent, :color,
            :material_name, :font_name, :font_text, :text_alignment,
            :text_spacing_x, :text_spacing_y, :disabled)
  json.image do
    case
    when layer.builtin_shape?
      json.normal asset_path("editor/#{layer.layer_type}/#{layer.material_name}.svg")
      json.md5sum ''
    when layer.layer_type == 'mask'
      json.normal layer.mask_image.url
      json.md5sum layer.mask_image.md5sum
    else
      json.normal layer.image.url
      json.md5sum layer.image.md5sum
    end
  end
  json.filter layer.filter
  json.filtered_image do
    case
    when layer.builtin_shape?
      json.normal asset_path("editor/#{layer.layer_type}/#{layer.material_name}.svg")
      json.md5sum ''
    when layer.layer_type == 'mask'
      json.normal layer.mask_image.url
      json.md5sum layer.mask_image.md5sum
    else
      json.normal layer.filtered_image.url
      json.md5sum layer.filtered_image.md5sum
    end
  end
  json.position layer.position
  json.masked layer.mask.present?
  json.masked_layers do
    json.array! layer.masked_layers do |layer|
      json.id layer.id
    end
  end
end
