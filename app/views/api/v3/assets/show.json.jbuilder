cache_json_for json, @asset do
  json.asset do
    json.partial! 'api/v3/asset', asset: @asset
  end
end
