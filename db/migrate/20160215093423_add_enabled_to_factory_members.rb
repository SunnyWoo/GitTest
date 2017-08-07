class AddEnabledToFactoryMembers < ActiveRecord::Migration
  def change
    add_column :factory_members, :enabled, :boolean, default: true
  end
end
