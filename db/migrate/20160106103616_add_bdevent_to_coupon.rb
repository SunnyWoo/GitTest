class AddBdeventToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :bdevent_id, :integer
  end
end
