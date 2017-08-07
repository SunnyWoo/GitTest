cache_json_for json, template do
  json.id template.id
  json.background_image do
    json.w320 template.background_image.w320.url
    json.w640 template.background_image.w640.url
  end
  json.overlay_image do
    json.w320 template.overlay_image.w320.url
    json.w640 template.overlay_image.w640.url
  end
  json.masks template.masks
end
