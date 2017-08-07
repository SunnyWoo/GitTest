class AddEventToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :event, :boolean, default: false
  end
end
