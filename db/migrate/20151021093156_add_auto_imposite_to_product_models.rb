class AddAutoImpositeToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :auto_imposite, :boolean, null: false, default: false
  end
end
