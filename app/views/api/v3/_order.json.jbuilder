cache_json_for json, order do
  json.call(order, :uuid, :price, :currency)
  json.status order.aasm_state
  json.status_i18n t("order.state.#{order.aasm_state}")
  json.payment order.payment
  json.ship_code order.ship_code
  json.logistics_info order.packages, :ship_code, :logistics_supplier_name
  if order.is_a?(Api::V3::OrderDecorator)
    json.payment_info order.payment_info
  elsif order.payment == 'neweb/atm'
    json.payment_info order.payment_info.merge(bank_id: order.payment_object.bank_id,
                                               bank_name: order.payment_object.bank_name)
  else
    json.payment_info order.payment_info
  end
  json.coupon order.coupon.try(:code) || ''

  if order.is_a?(Api::V3::OrderDecorator)
    json.order_price order.pricing
  else
    json.order_price do
      json.subtotal order.subtotal
      json.discount order.discount
      json.shipping_fee order.shipping_fee
      json.price order.price
    end
  end
  json.display_price do
    json.subtotal render_price(order.subtotal, currency_code: order.currency)
    json.discount render_price(order.discount, currency_code: order.currency)
    json.shipping_fee render_price(order.shipping_fee, currency_code: order.currency)
    json.price render_price(order.price, currency_code: order.currency)
  end
  json.call(order, :order_no, :created_at, :message)
  json.activities do
    activities = order.activities.where(key: %i(create paid shipped))
    json.partial! 'api/v3/activity', collection: activities, as: :activity
  end
  json.billing_info do
    json.partial! 'api/v3/billing_profile', profile: order.billing_info
  end
  json.shipping_info do
    json.partial! 'api/v3/billing_profile', profile: order.shipping_info
  end
  json.order_items do
    json.partial! 'api/v3/order_item', collection: order.order_items, as: :order_item
  end
end
