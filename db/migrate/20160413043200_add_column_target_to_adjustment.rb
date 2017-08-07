class AddColumnTargetToAdjustment < ActiveRecord::Migration
  def change
    add_column :adjustments, :target, :integer, null: false
  end
end
