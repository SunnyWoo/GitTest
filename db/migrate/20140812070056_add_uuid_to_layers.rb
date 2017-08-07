class AddUuidToLayers < ActiveRecord::Migration
  def change
    add_column :layers, :uuid, :string
    add_index :layers, :uuid
  end
end
