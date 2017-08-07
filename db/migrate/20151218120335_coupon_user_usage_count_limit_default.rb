class CouponUserUsageCountLimitDefault < ActiveRecord::Migration
  def up
    change_column :coupons, :user_usage_count_limit, :integer, default: -1
  end

  def down
    change_column :coupons, :user_usage_count_limit, :integer, default: nil
  end
end
