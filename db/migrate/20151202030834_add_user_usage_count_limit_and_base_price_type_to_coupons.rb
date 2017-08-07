class AddUserUsageCountLimitAndBasePriceTypeToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :user_usage_count_limit, :integer
    add_column :coupons, :base_price_type, :string

    Coupon.update_all(base_price_type: 'special', user_usage_count_limit: -1)
  end

  class Coupon < ActiveRecord::Base
  end
end
