class CreateRoleGroups < ActiveRecord::Migration
  def change
    create_table :role_groups do |t|
      t.string :name
      t.string :type
      t.timestamps
    end
  end
end
