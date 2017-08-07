json.cache! [cache_key_for_collection(collection)] do
  json.links do
    json.partial! 'api/v3/header_link_column', collection: collection, as: :link
  end
end
