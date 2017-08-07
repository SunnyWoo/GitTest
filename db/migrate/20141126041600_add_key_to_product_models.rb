class AddKeyToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :key, :string
    add_index :product_models, :key
    add_index :product_models, [:key, :category_id], unique: true
  end
end
