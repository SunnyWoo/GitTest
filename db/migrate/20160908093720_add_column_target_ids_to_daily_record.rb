class AddColumnTargetIdsToDailyRecord < ActiveRecord::Migration
  def change
    add_column :daily_records, :target_ids, :integer, array: true, default: []
  end
end
