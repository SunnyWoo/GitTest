# == Schema Information
#
# Table name: home_block_items
#
#  id         :integer          not null, primary key
#  block_id   :integer
#  image      :string(255)
#  href       :string(255)
#  image_meta :json
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

class HomeBlockItem < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include PreprocessImage

  serialize :image_meta, Hashie::Mash.pg_json_serializer

  translates :title, :subtitle, :pic, fallbacks_for_empty_translations: true
  globalize_accessors
  acts_as_list
  mount_uploader :image, HomeBlockItemImageUploader
  carrierwave_meta_composed :image_meta, :image, image_version: [:width, :height, :md5sum]
  preprocess_image :image, versions: %w(thumb)

  belongs_to :block, class_name: 'HomeBlock', touch: true

  scope :ordered, -> { order('position ASC') }

  Translation.class_eval do
    mount_uploader :pic, HomeBlockItemImageUploader
    belongs_to :item, class_name: 'HomeBlockItem', foreign_key: :home_block_item_id, touch: true
  end
end
