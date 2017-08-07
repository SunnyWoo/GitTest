class CreateTempShelves < ActiveRecord::Migration
  def change
    create_table :temp_shelves do |t|
      t.integer :print_item_id
      t.string :serial
      t.string :section
      t.timestamps
    end
    add_index :temp_shelves, :print_item_id
  end
end
