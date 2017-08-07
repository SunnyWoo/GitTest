class AddCouponIdToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :coupon_id, :integer, index: true
    change_column :coupons, :expired_at, :date
  end
end
