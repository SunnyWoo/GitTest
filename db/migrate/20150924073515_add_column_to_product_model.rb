class AddColumnToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :material, :string
    add_column :product_models, :weight, :float
  end
end
