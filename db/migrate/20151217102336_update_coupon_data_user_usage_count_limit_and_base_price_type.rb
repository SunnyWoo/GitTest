class UpdateCouponDataUserUsageCountLimitAndBasePriceType < ActiveRecord::Migration
  def change
    Coupon.where(user_usage_count_limit: nil).update_all(user_usage_count_limit: -1)
    Coupon.where(base_price_type: nil).update_all(base_price_type: 'special')
  end
end
