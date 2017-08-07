class AddCodeIdsToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :craft_id, :integer
    add_column :product_models, :spec_id, :integer
    add_column :product_models, :material_id, :integer
  end
end
