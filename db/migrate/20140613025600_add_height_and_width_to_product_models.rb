class AddHeightAndWidthToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :width, :float
    add_column :product_models, :height, :float
  end
end
