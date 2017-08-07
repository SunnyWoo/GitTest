class MigrateArtworksToWorks < ActiveRecord::Migration
  def change
    add_column :works, :user_type, :string
    add_column :works, :user_id, :integer
    add_column :works, :application_id, :integer
    add_column :archived_works, :user_type, :string
    add_column :archived_works, :user_id, :integer
    add_column :archived_works, :application_id, :integer
    add_column :archived_works, :name, :string

    Artwork.find_each do |artwork|
      work = Work.find_by(artwork_id: artwork.id)
      next unless work
      work.update(user_type: artwork.user_type,
                  user_id: artwork.user_id,
                  application_id: artwork.application_id)
    end

    ArchivedArtwork.find_each do |artwork|
      work = ArchivedWork.find_by(artwork_id: artwork.id)
      next unless work
      work.update(user_type: artwork.user_type,
                  user_id: artwork.user_id,
                  application_id: artwork.application_id)
    end
  end

  class Work < ActiveRecord::Base
  end

  class Artwork < ActiveRecord::Base
  end

  class ArchivedWork < ActiveRecord::Base
  end

  class ArchivedArtwork < ActiveRecord::Base
  end
end
