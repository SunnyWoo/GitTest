class AddImageMetaToLayers < ActiveRecord::Migration
  def change
    add_column :layers, :image_meta, :text
  end
end
