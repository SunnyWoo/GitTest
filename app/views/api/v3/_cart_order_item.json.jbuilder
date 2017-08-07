cache_json_for json, order_item do
  json.item do
    json.partial! 'api/v3/work', work: order_item.itemable
  end
  json.quantity order_item.quantity
end
