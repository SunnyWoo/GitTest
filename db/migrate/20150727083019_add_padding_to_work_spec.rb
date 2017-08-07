class AddPaddingToWorkSpec < ActiveRecord::Migration
  def change
    add_column :work_specs, :padding_top, :decimal, precision: 8, scale: 2, null: false, default: 0
    add_column :work_specs, :padding_right, :decimal, precision: 8, scale: 2, null: false, default: 0
    add_column :work_specs, :padding_bottom, :decimal, precision: 8, scale: 2, null: false, default: 0
    add_column :work_specs, :padding_left, :decimal, precision: 8, scale: 2, null: false, default: 0
  end
end
