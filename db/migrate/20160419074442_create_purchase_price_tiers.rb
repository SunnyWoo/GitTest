class CreatePurchasePriceTiers < ActiveRecord::Migration
  def change
    create_table :purchase_price_tiers do |t|
      t.integer :category_id
      t.integer :count_key
      t.decimal :price

      t.timestamps
    end

    add_index :purchase_price_tiers, :category_id
    add_index :purchase_price_tiers, :count_key
    add_index :purchase_price_tiers, [:category_id, :count_key], unique: true
  end
end
