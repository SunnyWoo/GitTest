# == Schema Information
#
# Table name: previews
#
#  id           :integer          not null, primary key
#  work_id      :integer
#  key          :string(255)
#  image        :string(255)
#  image_meta   :text
#  high_quality :boolean          default(FALSE), not null
#  created_at   :datetime
#  updated_at   :datetime
#  position     :integer
#  work_type    :string(255)
#

class Preview < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include PreprocessImage

  ORIGINAL_PRINT_IMAGE_KEY = 'original_image_without_watermark'.freeze
  PRESERVING_PREVIEW_KEYS = [ORIGINAL_PRINT_IMAGE_KEY].freeze
  STORE_PREVIEW_KEYS = %w(share download).freeze

  acts_as_list scope: :work_id

  belongs_to :work, polymorphic: true, touch: true

  serialize :image_meta, OpenStruct

  validates :key, uniqueness: { scope: [:work_id, :work_type] }

  mount_uploader :image, WorkUploader
  carrierwave_meta_composed :image_meta, :image, image_version: [:width, :height, :md5sum]
  preprocess_image :image, versions: %w(thumb)

  default_scope { order('position asc') }

  def image_aid=(aid)
    self.image = Attachment.find_by_aid!(aid).file
  end

  def archived_attributes
    { key: key, image: image, position: position }
  end
end
