json.cache! [cache_key_for_collection(@orders)] do
  json.orders do
    json.partial! 'api/v3/order', collection: @orders, as: :order
  end
end
