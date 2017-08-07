json.cache! [cache_key_for_collection(@tags)] do
  json.tags do
    json.partial! 'api/v3/tag', collection: @tags, as: :tag
  end
end
