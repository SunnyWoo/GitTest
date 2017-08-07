class AddBeginAtToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :begin_at, :date

    Coupon.update_all(begin_at: Date.yesterday)
  end

  class Coupon < ActiveRecord::Base
  end
end
