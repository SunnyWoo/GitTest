class AddApplicationToArchivedArtwork < ActiveRecord::Migration
  def change
    add_column :archived_artworks, :application_id, :integer
  end
end
