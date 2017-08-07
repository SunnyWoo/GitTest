class AddLockVersionToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :lock_version, :integer, null: false, default: 0
  end
end
