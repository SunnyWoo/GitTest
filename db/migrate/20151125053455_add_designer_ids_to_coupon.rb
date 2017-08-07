class AddDesignerIdsToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :designer_ids, :integer, array: true, default: []
  end
end
