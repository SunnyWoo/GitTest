class AddColumnEventToAdjustment < ActiveRecord::Migration
  def change
    add_column :adjustments, :event, :integer, null: false
  end
end
