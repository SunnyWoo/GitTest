json.cache! [cache_key_for_collection(@home_blocks)] do
  json.home_blocks do
    json.partial! 'api/v3/home_block', collection: @home_blocks, as: :block
  end
end
