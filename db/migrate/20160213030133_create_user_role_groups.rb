class CreateUserRoleGroups < ActiveRecord::Migration
  def change
    create_table :user_role_groups do |t|
      t.belongs_to :role_group
      t.belongs_to :user, polymorphic: true, index: true
      t.timestamps
    end
  end
end
