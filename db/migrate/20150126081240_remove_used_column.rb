class RemoveUsedColumn < ActiveRecord::Migration
  def change
    remove_column :coupons, :is_used, :boolean, null: false, default: false
  end
end
