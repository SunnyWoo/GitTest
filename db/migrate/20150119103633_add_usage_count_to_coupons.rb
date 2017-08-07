class AddUsageCountToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :usage_count, :integer, default: 0
  end
end
