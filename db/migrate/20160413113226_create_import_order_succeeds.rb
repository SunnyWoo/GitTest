class CreateImportOrderSucceeds < ActiveRecord::Migration
  def change
    create_table :import_order_succeeds do |t|
      t.integer :import_order_id
      t.integer :order_id
      t.string :guanyi_trade_code
      t.string :guanyi_platform_code

      t.timestamps
    end

    add_index :import_order_succeeds, :import_order_id
    add_index :import_order_succeeds, :guanyi_trade_code, unique: true

    remove_column :import_orders, :succeed
  end
end
