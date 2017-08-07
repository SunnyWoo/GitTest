class AddDiscountTypeAndPercentageToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :discount_type, :string
    add_column :coupons, :percentage, :decimal, precision: 8, scale: 2

    Coupon.update_all(discount_type: 'fixed')
  end

  class Coupon < ActiveRecord::Base
  end
end
