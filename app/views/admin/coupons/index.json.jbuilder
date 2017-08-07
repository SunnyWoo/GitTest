json.coupons @coupons do |coupon|
  json.extract!(coupon, :id, :title, :quantity, :children_count, :is_free_shipping, :is_not_include_promotion)
  json.render_coupon render_coupon_code(coupon)
  json.extract!(coupon, :begin_at, :expired_at, :usage_count,
                :usage_count_limit, :is_enabled)
  json.render_off_price render_off_price(coupon)
  json.links do
    json.edit do
      json.path edit_admin_coupon_path(coupon, locale: I18n.locale)
    end
    json.used_orders { json.path used_orders_admin_coupon_path(coupon, locale: I18n.locale, format: 'csv') }
  end
end

json.meta do
  json.partial! 'api/v3/pagination', models: @coupons
end
