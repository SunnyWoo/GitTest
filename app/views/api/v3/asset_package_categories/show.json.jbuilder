cache_json_for json, @category do
  json.asset_package_category do
    json.partial! 'api/v3/asset_package_category', category: @category
  end
end
