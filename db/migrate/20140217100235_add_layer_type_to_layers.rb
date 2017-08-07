class AddLayerTypeToLayers < ActiveRecord::Migration
  def change
    add_column :layers, :layer_type, :string
    add_index :layers, :layer_type
  end
end
