class AddConditionAndThresholdToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :condition, :string
    add_reference :coupons, :threshold, index: true

    Coupon.update_all(condition: 'none')
  end

  class Coupon < ActiveRecord::Base
  end
end
