cache_json_for json, output_file do
  json.extract!(output_file, :id, :key)
  json.file_url output_file.file.url
end
