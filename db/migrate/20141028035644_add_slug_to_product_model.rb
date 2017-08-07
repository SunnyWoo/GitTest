class AddSlugToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :slug, :string
    add_index :product_models, :slug, unique: true
  end
end
