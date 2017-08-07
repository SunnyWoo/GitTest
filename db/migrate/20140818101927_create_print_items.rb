class CreatePrintItems < ActiveRecord::Migration
  def change
    create_table :print_items do |t|
      t.integer :order_item_id
      t.string :model
      t.integer :timestamp_no, :limit => 8
      t.string :aasm_state
      t.datetime :print_at
      t.timestamps
    end
    add_index :print_items, :timestamp_no
    add_index :print_items, :model
  end
end
