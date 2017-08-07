class AddShelfColumns < ActiveRecord::Migration
  def change
    add_column :shelves, :serial_name, :string
    add_column :shelves, :safe_minimum_quantity, :integer, default: 0
  end
end
