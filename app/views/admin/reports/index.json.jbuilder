json.reports do
  json.array! @reports do |report|
    json.extract!(report, :date, :total_orders, :items_amount, :users_amount,
                  :subtotal, :discount, :shipping_fee, :price, :total_refund,
                  :total, :avg_order_price, :avg_per_user_price, :shipping_fee_discount)
  end
end
