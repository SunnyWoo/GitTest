cache_json_for json, @tag do
  json.tag do
    json.partial! 'api/v3/tag', tag: @tag
  end
end
