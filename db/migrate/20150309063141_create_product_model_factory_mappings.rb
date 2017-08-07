class CreateProductModelFactoryMappings < ActiveRecord::Migration
  def change
    create_table :product_model_factory_mappings do |t|
      t.integer :product_model_id
      t.integer :factory_id
      t.timestamps
    end
  end
end
