class RemoveEventFromCoupon < ActiveRecord::Migration
  def up
    Coupon.where(event: true).update_all(usage_count_limit: -1)

    remove_column :coupons, :event
  end

  def down
    add_column :coupons, :event, :boolean, default: false

    Coupon.where(usage_count_limit: -1).update_all(event: true)
  end

  class Coupon < ActiveRecord::Base
  end
end
