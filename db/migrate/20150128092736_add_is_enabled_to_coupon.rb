class AddIsEnabledToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :is_enabled, :boolean, default: true
  end
end