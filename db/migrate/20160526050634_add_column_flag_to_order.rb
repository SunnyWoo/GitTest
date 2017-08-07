class AddColumnFlagToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :flags, :integer
  end
end
