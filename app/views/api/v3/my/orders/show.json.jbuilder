cache_json_for json, @order do
  json.order do
    json.partial! 'api/v3/order', order: @order
  end
end
