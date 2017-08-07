# == Schema Information
#
# Table name: assets
#
#  id          :integer          not null, primary key
#  package_id  :integer
#  available   :boolean          default(FALSE), not null
#  uuid        :string(255)
#  type        :string(255)
#  raster      :string(255)
#  vector      :string(255)
#  image_meta  :json
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  colorizable :boolean          default(FALSE), not null
#

class Asset < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include HasUniqueUUID

  acts_as_list scope: :package

  mount_uploader :raster, DefaultWithMetaUploader
  mount_uploader :vector, RawUploader

  carrierwave_meta_composed :image_meta, :raster, image_version: [:width, :height, :md5sum]

  serialize :image_meta, Hashie::Mash.pg_json_serializer

  belongs_to :package, class_name: 'AssetPackage'

  validates :type, inclusion: %w(sticker coating foiling)
end

Asset.inheritance_column = :whatever
