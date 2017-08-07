class AddWorkStateToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :work_state, :integer, default: 0
    add_index :orders, :work_state
  end
end
