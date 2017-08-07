class CreateMasks < ActiveRecord::Migration
  def change
    create_table :masks do |t|
      t.string :material_name
      t.string :image

      t.timestamps
    end
    add_index :masks, :material_name, unique: true
  end
end
