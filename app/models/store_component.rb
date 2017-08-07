# == Schema Information
#
# Table name: store_components
#
#  id         :integer          not null, primary key
#  store_id   :integer
#  key        :string(255)
#  image      :string(255)
#  position   :integer
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

class StoreComponent < ActiveRecord::Base
  IMAGE_KEYS = %w(kv).freeze
  CONTENT_KEYS = %w(ticker).freeze
  KEYS = (IMAGE_KEYS + CONTENT_KEYS).map { |key| [key.humanize, key].map(&:freeze) }.freeze

  acts_as_list scope: [:store_id, :key]
  default_scope { order('key ASC, position ASC') }

  belongs_to :store
  mount_uploader :image, StoreComponentImageUploader

  validate :check_kv_image_dimensions, if: :kv_image?

  scope :kv, -> { where(key: 'kv') }
  scope :ticker, -> { where(key: 'ticker') }

  protected

  def kv_image?
    key == 'kv'
  end

  def check_kv_image_dimensions
    return if (image.width == 1242) && (image.height == 600)
    errors.add(:image, I18n.t('store.attributes.image.kv.dimension_error'))
  end
end
