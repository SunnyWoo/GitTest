class AddUserToArtworks < ActiveRecord::Migration
  def up
    add_reference :artworks, :user, index: true

    Artwork.find_each do |artwork|
      Work.where(artwork_id: artwork.id).each do |work|
        artwork.update(user_id: work.user_id)
      end
    end

    remove_reference :works, :user
  end

  def down
    add_reference :works, :user, index: true

    Artwork.find_each do |artwork|
      Work.where(artwork_id: artwork.id).each do |work|
        work.update(user_id: artwork.user_id)
      end
    end

    remove_reference :artworks, :user
  end

  class Work < ActiveRecord::Base
  end

  class Artwork < ActiveRecord::Base
  end
end
