class CreateShippingFees < ActiveRecord::Migration
  def change
    create_table :shipping_fees do |t|
      t.string :type
      t.integer :province_id
      t.integer :logistics_supplier_id
      t.string :country
      t.string :currency
      t.float :weight
      t.float :price
      t.timestamps
    end

    add_index :shipping_fees, :type
    add_index :shipping_fees, [:type, :country, :weight]
    add_index :shipping_fees, [:type, :province_id, :weight]
  end
end
