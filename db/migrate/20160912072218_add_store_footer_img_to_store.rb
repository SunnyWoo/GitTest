class AddStoreFooterImgToStore < ActiveRecord::Migration
  def change
    add_column :stores, :store_footer_img, :string
  end
end
