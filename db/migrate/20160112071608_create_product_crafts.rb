class CreateProductCrafts < ActiveRecord::Migration
  def change
    create_table :product_crafts do |t|
      t.string :description
      t.string :code

      t.timestamps
    end
  end
end
