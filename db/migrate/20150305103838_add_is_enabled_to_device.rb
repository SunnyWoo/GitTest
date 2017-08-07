class AddIsEnabledToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :is_enabled, :boolean, default: true
  end
end
