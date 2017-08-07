class AddColumnImgMetaToUser < ActiveRecord::Migration
  def change
    add_column :users, :image_meta, :json
  end
end
