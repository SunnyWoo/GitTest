class OrderItemPolicy < PrintPolicy
  # 拋單完成, 商品貼紙
  permit %i(delivery_complete product_ticker)
end
