json.cache! [cache_key_for_collection(@orders)] do
  json.orders do
    json.partial! 'api/v3/order', collection: @orders, as: :order
  end
end
json.meta do
  json.orders_count @orders.count
end
