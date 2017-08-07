class AddColumnWorkIdsToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :work_gids, :text, array: true, default: []
  end
end
