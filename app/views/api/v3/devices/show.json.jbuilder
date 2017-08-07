cache_json_for json, @device do
  json.device do
    json.partial! 'api/v3/device', device: @device
  end
end
