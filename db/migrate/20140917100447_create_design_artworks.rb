class CreateDesignArtworks < ActiveRecord::Migration
  def change
    create_table :design_artworks do |t|
      t.belongs_to :design, index: true
      t.belongs_to :artwork, index: true

      t.timestamps
    end
  end
end
