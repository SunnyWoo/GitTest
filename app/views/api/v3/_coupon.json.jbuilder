cache_json_for json, coupon do
  json.extract!(coupon, :id, :quantity, :title, :code, :usage_count,
                :usage_count_limit, :price_tier_id, :discount_type, :percentage,
                :condition, :apply_target, :begin_at, :expired_at, :user_usage_count_limit,
                :base_price_type)

  json.coupon_rules do
    json.partial! 'api/v3/coupon_rule', collection: coupon.coupon_rules, as: :coupon_rule
  end
end
