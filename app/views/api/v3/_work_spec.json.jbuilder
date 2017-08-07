cache_json_for json, spec do
  json.call(spec, :id, :name, :description, :width, :height, :dpi)
  json.background_image spec.background_image.url
  json.overlay_image spec.overlay_image.url
  json.padding_top spec.padding_top.to_s
  json.padding_right spec.padding_right.to_s
  json.padding_bottom spec.padding_bottom.to_s
  json.padding_left spec.padding_left.to_s
  json.__deprecated 'WorkSpec is not longer available'
end
