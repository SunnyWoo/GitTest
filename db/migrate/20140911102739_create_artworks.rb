class CreateArtworks < ActiveRecord::Migration
  def change
    create_table :artworks do |t|
      t.belongs_to :model, index: true
      t.string :uuid
      t.string :name
      t.text :description
      t.integer :work_type
      t.boolean :finished, default: false
      t.boolean :featured, default: false
      t.integer :position

      t.timestamps
    end

    add_reference :works, :artwork, index: true

    Work.find_each do |work|
      artwork = Artwork.create(model_id: work.model_id,
                               uuid: UUIDTools::UUID.timestamp_create.to_s,
                               name: work.name,
                               description: work.description,
                               work_type: work.work_type,
                               finished: work.finished,
                               featured: work.feature)
      work.update(artwork_id: artwork.id)
    end
  end

  class Work < ActiveRecord::Base
  end

  class Artwork < ActiveRecord::Base
  end
end
