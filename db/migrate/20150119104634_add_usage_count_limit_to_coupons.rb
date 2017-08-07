class AddUsageCountLimitToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :usage_count_limit, :integer, default: -1
  end
end
