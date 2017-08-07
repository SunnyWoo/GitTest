json.cache! [cache_key_for_collection(@layers)] do
  json.layers do
    json.partial! 'api/v3/archived_layer', collection: @layers, as: :layer
  end
end
