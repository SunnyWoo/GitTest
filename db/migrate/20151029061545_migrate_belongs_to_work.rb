class MigrateBelongsToWork < ActiveRecord::Migration
  def change
    rename_column :wishlist_items, :artwork_id, :work_id
    rename_column :taggings, :artwork_id, :work_id
    rename_column :work_sets, :artwork_ids, :work_ids

    WishlistItem.find_each do |item|
      work = Work.find_by(artwork_id: item.work_id)
      next unless work
      item.update(work_id: work.id)
    end

    Tagging.find_each do |tagging|
      work = Work.find_by(artwork_id: tagging.work_id)
      next unless work
      tagging.update(work_id: work.id)
    end

    WorkSet.find_each do |work_set|
      works = Work.where(artwork_id: work_set.work_ids)
      work_set.update(work_ids: works.pluck(:id))
    end
  end

  class Work < ActiveRecord::Base
  end

  class Artwork < ActiveRecord::Base
  end

  class WishlistItem < ActiveRecord::Base
  end

  class Tagging < ActiveRecord::Base
  end

  class WorkSet < ActiveRecord::Base
  end
end
