class AddApplyCountLimitToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :apply_count_limit, :integer

    Coupon.where(apply_target: 'once').update_all(apply_count_limit: 1)
    Coupon.where(apply_target: 'per_item').update_all(apply_count_limit: -1)
  end

  class Coupon < ActiveRecord::Base
  end
end
