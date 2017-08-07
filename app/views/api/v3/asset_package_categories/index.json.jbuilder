json.cache! [cache_key_for_collection(@categories)] do
  json.asset_package_categories do
    json.partial! 'api/v3/asset_package_category', collection: @categories, as: :category
  end
end
