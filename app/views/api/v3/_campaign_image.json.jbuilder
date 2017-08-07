cache_json_for json, image do
  json.call(image, :id)
  json.url image.file.url
  json.call(image, :key, :desc)
end
