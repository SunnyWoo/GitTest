cache_json_for json, @package do
  json.asset_package do
    json.partial! 'api/v3/asset_package', package: @package
  end
end
