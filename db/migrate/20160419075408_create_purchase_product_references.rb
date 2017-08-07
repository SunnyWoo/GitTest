class CreatePurchaseProductReferences < ActiveRecord::Migration
  def change
    create_table :purchase_product_references do |t|
      t.integer :product_id
      t.integer :category_id
      t.integer :b2c_count

      t.timestamps
    end

    add_index :purchase_product_references, :product_id
    add_index :purchase_product_references, :category_id
  end
end
