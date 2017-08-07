class AddSourceToArtwork < ActiveRecord::Migration
  def change
    add_column :artworks, :application_id, :integer
  end
end