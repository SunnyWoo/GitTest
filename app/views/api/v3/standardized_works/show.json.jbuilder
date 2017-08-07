cache_json_for json, @work do
  json.standardized_work do
    json.partial! 'api/v3/standardized_work', work: @work
  end
end
