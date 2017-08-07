cache_json_for json, @attachment do
  json.attachment do
    json.partial! 'api/v3/attachment', attachment: @attachment
  end
end
