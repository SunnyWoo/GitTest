cache_json_for json, @order do
  json.cart do
    json.partial! 'api/v3/cart', order: @order
  end
  json.meta do
    json.items_count @cart.items.count
    json.current_currency_code @current_currency_code
  end
end
