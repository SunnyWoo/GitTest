class AddAdjustmentConstraint < ActiveRecord::Migration
  def change
    change_column :adjustments, :value, :float, null: false
  end
end
