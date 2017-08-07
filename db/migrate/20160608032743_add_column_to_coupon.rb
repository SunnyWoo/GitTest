class AddColumnToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :is_free_shipping, :boolean, default: false
    add_column :coupons, :is_not_include_promotion, :boolean, default: false
  end
end
