json.cache! [cache_key_for_collection(@home_links)] do
  json.home_links do
    json.partial! 'api/v3/home_link', collection: @home_links, as: :home_link
  end
end
