cache_json_for json, @layer do
  json.layer do
    json.partial! 'api/v3/archived_layer', layer: @layer
  end
end
