class ChageUserRoleColumnType < ActiveRecord::Migration
  def change
    remove_column :users, :role
    add_column :users, :role, :integer
  end
end
