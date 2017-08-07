json.cache! [cache_key_for_collection(@packages)] do
  json.asset_packages do
    json.partial! 'api/v3/asset_package', collection: @packages, as: :package
  end
end
