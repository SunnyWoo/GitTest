cache_json_for json, coupon_rule do
  json.id coupon_rule.id
  json.quantity coupon_rule.quantity
  json.condition coupon_rule.condition
  json.threshold_prices coupon_rule.threshold_prices
  json.designer_ids coupon_rule.designer_ids
  json.product_model_ids coupon_rule.product_model_ids
  json.product_category_ids coupon_rule.product_category_ids
  json.work_gids coupon_rule.work_gids
end
