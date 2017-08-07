class AddAdjustmentsQuantity < ActiveRecord::Migration
  def change
    add_column :adjustments, :quantity, :integer, default: 1, null: false
  end
end
