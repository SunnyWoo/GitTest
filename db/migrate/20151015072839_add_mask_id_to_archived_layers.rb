class AddMaskIdToArchivedLayers < ActiveRecord::Migration
  def change
    add_column :archived_layers, :mask_id, :integer
    add_index :archived_layers, :mask_id
  end
end
