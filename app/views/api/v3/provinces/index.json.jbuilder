json.cache! [cache_key_for_collection(@provinces)] do
  json.provinces do
    json.partial! 'api/v3/province', collection: @provinces, as: :province
  end
end
