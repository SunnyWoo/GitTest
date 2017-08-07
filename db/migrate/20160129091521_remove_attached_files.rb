class RemoveAttachedFiles < ActiveRecord::Migration
  def up
    Layer.where.not(attached_image_id: nil).find_each do |layer|
      layer.update(image: layer.attached_image.file)
    end
    Layer.where.not(attached_filtered_image_id: nil).find_each do |layer|
      layer.update(filtered_image: layer.attached_filtered_image.file)
    end
    Work.where.not(attached_cover_image_id: nil).find_each do |work|
      work.update(cover_image: work.attached_cover_image.file)
    end

    # TODO: 等一下次 release 移除
    # remove_column :layers, :attached_image_id
    # remove_column :layers, :attached_filtered_image_id
    # remove_column :works, :attached_cover_image_id
  end

  def down
  end

  class Layer < ActiveRecord::Base
    serialize :image_meta, OpenStruct
    belongs_to :attached_image, class_name: 'Attachment'
    belongs_to :attached_filtered_image, class_name: 'Attachment'
    mount_uploader :image, DefaultWithMetaUploader
    mount_uploader :filtered_image, DefaultWithMetaUploader
  end

  class Work < ActiveRecord::Base
    serialize :image_meta, Hashie::Mash.pg_json_serializer
    belongs_to :attached_cover_image, class_name: 'Attachment'
    mount_uploader :cover_image, CoverImageUploader

    def cover_image_stored!
    end
  end
end
