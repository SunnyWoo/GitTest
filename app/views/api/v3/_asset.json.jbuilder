cache_json_for json, asset do
  json.call(asset, :id, :uuid, :type)
  if asset.raster.blank?
    json.image asset.vector.url
  else
    json.image asset.raster.negate.url
  end
  json.raster asset.raster.url
  json.vector asset.vector.url
  json.colorizable asset.colorizable
end
