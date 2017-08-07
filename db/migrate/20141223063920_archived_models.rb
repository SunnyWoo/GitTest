class ArchivedModels < ActiveRecord::Migration
  def change
    create_table :archived_artworks do |t|
      t.belongs_to :original_artwork, index: true
      t.belongs_to :model, index: true
      t.belongs_to :user, index: true, polymorphic: true
      t.string :name
      t.timestamps
    end

    create_table :archived_works do |t|
      t.belongs_to :original_work, index: true
      t.belongs_to :artwork, index: true
      t.belongs_to :spec, index: true
      t.string :cover_image
      t.string :print_image
      t.string :order_image
      t.string :fixed_image
      t.json :image_meta
      t.timestamps
    end

    create_table :archived_layers do |t|
      t.belongs_to :work, index: true
      t.string :layer_type
      t.float :orientation,                     default: 0.0
      t.float :scale_x, :scale_y,               default: 1.0
      t.string :color
      t.float :transparent,                     default: 1.0
      t.string :font_name
      t.text :font_text
      t.string :image
      t.string :filter
      t.string :filtered_image
      t.string :material_name
      t.float :position_x, :position_y,         default: 0.0
      t.float :text_spacing_x, :text_spacing_y, default: 0.0
      t.string :text_alignment
      t.integer :position
      t.json :image_meta
      t.timestamps
    end
  end
end
