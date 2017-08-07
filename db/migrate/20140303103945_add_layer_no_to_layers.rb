class AddLayerNoToLayers < ActiveRecord::Migration
  def change
    add_column :layers, :layer_no, :string
  end
end
