cache_json_for json, banner do
  json.call(banner, :id, :name, :deeplink)
  json.image banner.image.url
  json.call(banner, :platforms, :url)
end
