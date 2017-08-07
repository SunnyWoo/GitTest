class AddCouponIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :coupon_id, :integer
    remove_column :coupons, :order_id
  end
end
