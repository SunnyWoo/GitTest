json.cart do
  json.price render_price(@order.price, currency_code: @order.currency)
  json.subtotal render_price(@order.subtotal, currency_code: @order.currency)
  json.shipping_fee render_price(@order.shipping_price, currency_code: @order.currency)
  json.discount render_price(@order.discount, currency_code: @order.currency)

  json.coupon_code @order.embedded_coupon.try(:code)
  json.order_item_quantity_total @order.order_items.inject(0) { |sum, item| sum + item.quantity }
  json.payment @order.payment
  json.payment_path begin_payment_path(@order.payment_method)
  json.shipping_info_shipping_way @order.shipping_info_shipping_way
  json.order_items do
    json.partial! 'order_item', collection: @order.order_items, as: :order_item
  end
  json.currency @order.currency
  json.billing_info do
    json.partial! 'billing_profile', profile: @order.billing_info
  end
  json.shipping_info do
    json.partial! 'billing_profile', profile: @order.shipping_info
  end
end
