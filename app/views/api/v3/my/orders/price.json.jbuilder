json.order do
  json.currency @order.currency
  json.coupon @order.coupon.try(:code) || ''
  json.price @order.pricing
  json.display_price do
    json.subtotal render_price(@order.subtotal, currency_code: @order.currency)
    json.discount render_price(@order.discount, currency_code: @order.currency)
    json.shipping_fee render_price(@order.shipping_fee, currency_code: @order.currency)
    json.price render_price(@order.price, currency_code: @order.currency)
  end
end

json.meta do
  json.items_count @order.print_items_count
end
