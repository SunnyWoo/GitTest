class CreateShelves < ActiveRecord::Migration
  def change
    create_table :shelves do |t|
      t.string :serial
      t.string :section
      t.string :name
      t.integer :quantity, default: 0
      t.integer :factory_id
      t.timestamps
    end

    add_index :shelves, [:serial, :section], unique: true
  end
end
