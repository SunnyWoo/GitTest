class CreateProductSpecs < ActiveRecord::Migration
  def change
    create_table :product_specs do |t|
      t.string :description
      t.string :code

      t.timestamps
    end
  end
end
