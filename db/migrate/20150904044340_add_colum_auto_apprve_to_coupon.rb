class AddColumAutoApprveToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :auto_approve, :boolean, default: false
  end
end
