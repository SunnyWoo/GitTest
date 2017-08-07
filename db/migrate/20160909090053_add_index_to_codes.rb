class AddIndexToCodes < ActiveRecord::Migration
  def change
    add_index :product_category_codes, :code, unique: true
    add_index :product_crafts, :code, unique: true
    add_index :product_materials, :code, unique: true
    add_index :product_specs, :code, unique: true
  end
end
