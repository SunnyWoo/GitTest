class AddImageToProductCategory < ActiveRecord::Migration
  def change
    add_column :product_categories, :image, :string
  end
end
