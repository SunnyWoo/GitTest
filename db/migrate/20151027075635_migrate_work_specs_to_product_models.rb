class MigrateWorkSpecsToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :extra_info, :json, null: false, default: {}

    WorkSpec.find_each do |spec|
      next unless spec.model
      spec.model.update(width: spec.width,
                        height: spec.height,
                        dpi: spec.dpi,
                        background_image: spec.background_image,
                        overlay_image: spec.overlay_image,
                        shape: spec.shape,
                        alignment_points: spec.alignment_points,
                        padding_top: spec.padding_top,
                        padding_right: spec.padding_right,
                        padding_bottom: spec.padding_bottom,
                        padding_left: spec.padding_left,
                        background_color: spec.background_color)
    end
  end

  class ProductModel < ActiveRecord::Base
    serialize :extra_info, Hashie::Mash.pg_json_serializer
    store_accessor :extra_info, %w(width height dpi background_image overlay_image
                                   shape alignment_points padding_top
                                   padding_right padding_bottom padding_left
                                   background_color)

    mount_uploader :background_image, DefaultUploader, serialize_to: :extra_info
    mount_uploader :overlay_image, DefaultUploader, serialize_to: :extra_info

    def self.actual_class_name
      'ProductModel'
    end
  end

  class WorkSpec < ActiveRecord::Base
    belongs_to :model, class_name: 'ProductModel'

    mount_uploader :background_image, DefaultUploader
    mount_uploader :overlay_image, DefaultUploader

    def self.actual_class_name
      'WorkSpec'
    end
  end
end
