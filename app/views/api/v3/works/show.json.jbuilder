include_layers ||= false
cache_json_for json, @work do
  json.work do
    json.partial! 'api/v3/work', work: @work, include_layers: include_layers
  end
end
