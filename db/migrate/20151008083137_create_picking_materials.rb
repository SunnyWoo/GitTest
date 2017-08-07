class CreatePickingMaterials < ActiveRecord::Migration
  def change
    create_table :picking_materials do |t|
      t.integer :model_id
      t.string :material
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :picking_materials, :model_id
  end
end
