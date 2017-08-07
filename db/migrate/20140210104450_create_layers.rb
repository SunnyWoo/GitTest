class CreateLayers < ActiveRecord::Migration
  def change
    create_table :layers do |t|
      t.belongs_to :work, index: true
      t.string :position_x
      t.string :position_y
      t.float :orientation
      t.float :scale_x
      t.float :scale_y
      t.string :color
      t.float :transparent
      t.string :font_name
      t.string :font_text
      t.string :image
      t.string :name

      t.timestamps
    end
  end
end
