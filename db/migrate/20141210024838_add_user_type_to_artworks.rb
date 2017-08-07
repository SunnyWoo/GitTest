class AddUserTypeToArtworks < ActiveRecord::Migration
  def change
    add_column :artworks, :user_type, :string

    Artwork.update_all(user_type: 'User')
  end

  class Artwork < ActiveRecord::Base
  end
end
