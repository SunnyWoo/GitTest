class SetOrderEmbeddedCouponBasePriceType < ActiveRecord::Migration
  def change
    Order.where.not(embedded_coupon: nil).find_each do |order|
      if order.embedded_coupon.base_price_type.blank?
        if order.embedded_coupon.apply_target == 'once'
          apply_count_limit = 1
        elsif order.embedded_coupon.apply_target == 'per_item'
          apply_count_limit = -1
        end
        base_price_type = order.coupon.present? ? order.coupon.base_price_type : 'special'
        update_embedded_coupon = { 'apply_count_limit' => apply_count_limit, 'base_price_type' => base_price_type }
        embedded_coupon = EmbeddedCoupon.new(order.embedded_coupon.as_json.merge(update_embedded_coupon))
        order.update_column(:embedded_coupon, embedded_coupon.as_json)
      end
    end
  end
end
