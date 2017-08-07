json.cache! [cache_key_for_collection(@block_items)] do
  json.block_items do
    json.partial! 'api/v3/home_block_item', collection: @block_items, as: :item
  end
end
