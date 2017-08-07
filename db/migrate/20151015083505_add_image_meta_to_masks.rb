class AddImageMetaToMasks < ActiveRecord::Migration
  def change
    add_column :masks, :image_meta, :json
  end
end
