json.extract!(order, :id, :order_no, :created_at, :platform, :user_agent,
              :shipping_info_shipping_way)
json.remote_order_no order.remote_info['order_no']
json.links do
  json.show url_for([:admin, order, locale: I18n.locale])
  json.approve url_for([:admin, order, :approve, locale: I18n.locale])
  json.create_note admin_noteable_notes_path(order)
end
json.order_price do
  json.subtotal order.subtotal
  json.discount order.discount
  json.shipping_fee order.shipping_fee
  json.price order.price
  json.price_in_currency render_price(order.price, currency_code: order.currency)
end
json.coupon_code order.coupon.try(:code)
json.message order.message
json.billing_info do
  json.partial! 'api/v3/billing_profile', profile: order.billing_info
end
json.shipping_info do
  json.partial! 'api/v3/billing_profile', profile: order.shipping_info
end
json.order_items do
  json.partial! 'api/v3/order_item', collection: order.order_items, as: :order_item
end
json.notes do
  json.partial! 'api/v3/note', collection: order.notes, as: :note
end
json.tags order.tags
