class CreatePreviews < ActiveRecord::Migration
  def change
    create_table :previews do |t|
      t.belongs_to :work, index: true
      t.string :key
      t.string :image
      t.text :image_meta
      t.boolean :high_quality, default: false, null: false

      t.timestamps
    end

    add_index :previews, [:work_id, :key]
  end
end
