class RemoveDimensionFromProductModels < ActiveRecord::Migration
  def change
    remove_column :product_models, :width, :float
    remove_column :product_models, :height, :float

    add_column :product_models, :available, :boolean, default: false
  end
end
