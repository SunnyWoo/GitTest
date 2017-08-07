class CreateRoleRoleGroups < ActiveRecord::Migration
  def change
    create_table :role_role_groups do |t|
      t.belongs_to :role
      t.belongs_to :role_group

      t.timestamps
    end
  end
end
