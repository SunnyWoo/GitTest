# json.cache! @work do
  json.work do
    json.partial! 'api/v3/work', work: @work, include_layers: true
  end
# end
