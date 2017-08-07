cache_json_for json, tag do
  json.extract!(tag, :id, :name, :text)
end
