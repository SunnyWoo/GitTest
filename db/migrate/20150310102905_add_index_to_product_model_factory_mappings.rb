class AddIndexToProductModelFactoryMappings < ActiveRecord::Migration
  def change
    add_index :product_model_factory_mappings, [:factory_id, :product_model_id], unique: true, name: "index_model_factory_id_uniq"
  end
end
