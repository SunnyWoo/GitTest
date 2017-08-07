json.orders do
  json.partial! 'unapproved_order', collection: @orders, as: :order
end
json.meta do
  json.partial! 'api/v3/pagination', models: @orders
end
