# == Schema Information
#
# Table name: masks
#
#  id            :integer          not null, primary key
#  material_name :string(255)
#  image         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  image_meta    :json
#

class Mask < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord

  mount_uploader :image, DefaultWithMetaUploader

  carrierwave_meta_composed :image_meta, :image, image_version: [:width, :height, :md5sum]

  serialize :image_meta, Hashie::Mash.pg_json_serializer

  validates :material_name, presence: true
end
