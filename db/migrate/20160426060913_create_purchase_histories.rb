class CreatePurchaseHistories < ActiveRecord::Migration
  def change
    create_table :purchase_histories do |t|
      t.integer :duration_id
      t.integer :product_id
      t.string :category_name
      t.integer :b2c_count
      t.float :price
      t.json :price_tiers

      t.timestamps
    end

    add_index :purchase_histories, :duration_id
  end
end
