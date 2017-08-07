cache_json_for json, order do
  ### For Legacy Support, It could be removed once website updated
  json.price render_price(order.price, currency_code: order.currency)
  json.subtotal render_price(order.subtotal, currency_code: order.currency)
  json.shipping_fee render_price(order.shipping_price, currency_code: order.currency)
  json.discount render_price(order.discount, currency_code: order.currency)
  ### End of Legacy Support

  json.order_price order.pricing
  json.display_price do
    json.subtotal render_price(order.subtotal, currency_code: order.currency)
    json.discount render_price(order.discount, currency_code: order.currency)
    json.shipping_fee render_price(order.shipping_fee, currency_code: order.currency)
    json.price_without_shipping_fee render_price(order.price_without_shipping_fee, currency_code: order.currency)
    json.price render_price(order.price, currency_code: order.currency)
  end

  json.coupon_code order.embedded_coupon.try(:code)
  json.order_item_quantity_total order.order_items.inject(0) { |sum, item| sum + item.quantity }
  json.payment order.payment
  json.payment_path begin_payment_path(order.payment_method)
  json.shipping_info_shipping_way order.shipping_info_shipping_way
  json.order_items do
    json.partial! 'api/v3/cart_order_item', collection: order.order_items, as: :order_item
  end
  json.currency order.currency
end
