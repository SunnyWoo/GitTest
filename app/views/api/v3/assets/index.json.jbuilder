json.cache! [cache_key_for_collection(@assets)] do
  json.assets do
    json.partial! 'api/v3/asset', collection: @assets, as: :asset
  end
end
