class AddImageMetaToWorks < ActiveRecord::Migration
  def change
    add_column :works, :image_meta, :text
  end
end
