class AddDisabledToLayers < ActiveRecord::Migration
  def change
    add_column :layers, :disabled, :boolean, null: false, default: false
    add_column :archived_layers, :disabled, :boolean, null: false, default: false
  end
end
