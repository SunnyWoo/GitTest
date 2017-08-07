class CreateProductModelDescriptionImages < ActiveRecord::Migration
  def change
    create_table :product_model_description_images do |t|
      t.integer :product_id
      t.string :image

      t.timestamps
    end

    add_index :product_model_description_images, :product_id
  end
end
