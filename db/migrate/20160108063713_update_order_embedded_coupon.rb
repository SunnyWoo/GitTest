class UpdateOrderEmbeddedCoupon < ActiveRecord::Migration
  def change
    Order.where.not(embedded_coupon: nil).find_each do |order|
      embedded_coupon = order.embedded_coupon
      next if embedded_coupon.condition.in?(%w(none shipping_fee))
      coupon_rule = { 'condition' => embedded_coupon.condition,
                      'threshold_prices' => embedded_coupon.threshold_prices,
                      'product_model_ids' => embedded_coupon.product_model_ids,
                      'designer_ids' => embedded_coupon.designer_ids,
                      'product_category_ids' => embedded_coupon.product_category_ids,
                      'work_gids' => embedded_coupon.work_gids,
                      'quantity' => 1 }
      update_embedded_coupon = { 'condition' => 'simple', 'coupon_rules' => [coupon_rule] }
      embedded_coupon = EmbeddedCoupon.new(order.embedded_coupon.as_json.merge(update_embedded_coupon))
      order.update_column(:embedded_coupon, embedded_coupon.as_json)
    end
  end
end
