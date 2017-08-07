class CreateShelfMaterials < ActiveRecord::Migration
  def change
    create_table :shelf_materials do |t|
      t.integer :factory_id
      t.string :name
      t.string :serial, null: false
      t.string :image
      t.integer :quantity, null: false, default: 0
      t.integer :safe_minimum_quantity, default: 0
      t.integer :scrapped_quantity, default: 0
      t.string :aasm_state

      t.timestamps
    end

    add_index :shelf_materials, :factory_id
    add_index :shelf_materials, :serial, unique: true
    add_index :shelf_materials, [:serial, :factory_id], unique: true
  end
end
