class ChangeLayerTypeColumnType < ActiveRecord::Migration
  def change
    change_column :layers, :layer_type, 'integer USING CAST(layer_type AS integer)'
  end
end
