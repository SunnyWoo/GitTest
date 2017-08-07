class CreateWishlistItems < ActiveRecord::Migration
  def change
    create_table :wishlist_items do |t|
      t.belongs_to :wishlist, index: true
      t.belongs_to :artwork, index: true

      t.timestamps
    end
  end
end
