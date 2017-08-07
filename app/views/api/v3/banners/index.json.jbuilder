json.cache! [cache_key_for_collection(@banners)] do
  json.banners do
    json.partial! 'api/v3/banner', collection: @banners, as: :banner
  end
end
