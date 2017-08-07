# == Schema Information
#
# Table name: preview_samples
#
#  id                  :integer          not null, primary key
#  preview_composer_id :integer
#  work_id             :integer
#  result              :string(255)
#  image_meta          :text
#  created_at          :datetime
#  updated_at          :datetime
#

class PreviewSample < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include PreprocessImage

  serialize :image_meta, OpenStruct

  belongs_to :preview_composer
  belongs_to :work

  mount_uploader :result, WorkUploader
  carrierwave_meta_composed :image_meta, :result, image_version: [:width, :height, :md5sum]
  preprocess_image :result, versions: %w(sample)
end
