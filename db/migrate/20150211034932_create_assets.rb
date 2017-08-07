class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.belongs_to :package, index: true
      t.boolean :available, null: false, default: false
      t.string :uuid
      t.string :type
      t.string :raster
      t.string :vector
      t.json :image_meta
      t.integer :position

      t.timestamps
    end

    add_index :assets, :uuid, unique: true
  end
end
