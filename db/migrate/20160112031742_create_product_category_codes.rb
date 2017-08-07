class CreateProductCategoryCodes < ActiveRecord::Migration
  def change
    create_table :product_category_codes do |t|
      t.string :description
      t.string :code

      t.timestamps
    end
  end
end
