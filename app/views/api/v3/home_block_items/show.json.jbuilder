cache_json_for json, @block_item do
  json.block_item do
    json.partial! 'api/v3/home_block_item', item: @block_item
  end
end
