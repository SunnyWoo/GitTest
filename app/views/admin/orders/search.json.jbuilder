json.orders do
  json.array! @orders do |order|
    json.order_no do
      json.order_no order.order_no
      json.link admin_order_path(order, locale: I18n.locale)
    end
    json.remote_order_no order.remote_info['order_no']
    json.images order.order_items.map { |item| item.itemable_order_image.try(:thumb).try(:url) }
    json.aasm_state t("order.state.#{order.aasm_state}")
    json.created_at l(order.created_at, format: :long)
    json.render_twd_price number_to_currency(order.render_twd_price)
    json.shipping_way order.shipping_info_shipping_way
    json.country order.shipping_info_country
    json.platform order.platform
    json.render_cny_price number_to_currency(order.currency_price('CNY'), locale: 'zh-CN')
    json.default_currency Region.default_currency
    json.tags order.tags
    json.flags order.flag_names
  end
end
json.meta do
  json.partial! 'api/v3/pagination', models: @orders
end
