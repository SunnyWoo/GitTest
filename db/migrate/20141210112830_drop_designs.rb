class DropDesigns < ActiveRecord::Migration
  def change
    drop_table :designs
    drop_table :design_artworks
  end
end
