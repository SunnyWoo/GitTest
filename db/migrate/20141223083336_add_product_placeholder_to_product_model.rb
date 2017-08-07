class AddProductPlaceholderToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :product_placeholder, :string
  end
end
