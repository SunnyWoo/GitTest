class RemoveCreatorNameFromLayers < ActiveRecord::Migration
  def change
    remove_column :layers, :creator_name, :string
    rename_column :layers, :name, :material_name
  end
end
