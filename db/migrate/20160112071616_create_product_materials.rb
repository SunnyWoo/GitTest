class CreateProductMaterials < ActiveRecord::Migration
  def change
    create_table :product_materials do |t|
      t.string :description
      t.string :code

      t.timestamps
    end
  end
end
