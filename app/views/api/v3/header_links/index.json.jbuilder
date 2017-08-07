json.cache! [cache_key_for_collection(@header_links)] do
  json.header_links do
    json.partial! 'api/v3/header_link', collection: @header_links, as: :link
  end
end
