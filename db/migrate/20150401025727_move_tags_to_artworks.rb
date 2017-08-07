class MoveTagsToArtworks < ActiveRecord::Migration
  def up
    rename_column :taggings, :work_id, :artwork_id

    work_ids = Tagging.pluck(:artwork_id)
    Work.where(id: work_ids).find_each do |work|
      Tagging.where(artwork_id: work.id).update_all(artwork_id: work.artwork_id)
    end
  end

  def down
    rename_column :taggings, :artwork_id, :work_id

    artwork_ids = Tagging.pluck(:work_id)
    Artwork.where(id: work_ids).find_each do |artwork|
      Tagging.where(work_id: artwork.id).update_all(work_id: artwork.works.first.id)
    end
  end

  class Artwork < ActiveRecord::Base
  end

  class Work < ActiveRecord::Base
  end

  class Tagging < ActiveRecord::Base
  end
end
