class CreateWorkOutputFiles < ActiveRecord::Migration
  def change
    create_table :work_output_files do |t|
      t.belongs_to :work, index: true, polymorphic: true
      t.string :key
      t.string :file
      t.json :image_meta, null: false, default: {}

      t.timestamps
    end
  end
end
