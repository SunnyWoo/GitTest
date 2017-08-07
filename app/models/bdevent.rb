# == Schema Information
#
# Table name: bdevents
#
#  id         :integer          not null, primary key
#  uuid       :string(255)
#  starts_at  :datetime
#  ends_at    :datetime
#  priority   :integer          default(1)
#  is_enabled :boolean
#  event_type :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#  background :string(255)
#

class Bdevent < ActiveRecord::Base
  include ActsAsIsEnabled

  validates :starts_at, :ends_at, presence: true

  has_one :bdevent_redeem, -> { where(parent_id: nil) }
  accepts_nested_attributes_for :bdevent_redeem

  has_many :bdevent_images
  has_many :bdevent_works, foreign_key: :bdevent_id
  has_many :works, through: :bdevent_works, source: :work, source_type: 'Work'
  has_many :bdevent_products
  has_many :products, through: :bdevent_products
  accepts_nested_attributes_for :bdevent_works, allow_destroy: true
  accepts_nested_attributes_for :bdevent_images, allow_destroy: true
  accepts_nested_attributes_for :bdevent_products, allow_destroy: true

  translates :title, :desc, :banner, :coming_soon_image, :ticker, :coupon_desc, fallbacks_for_empty_translations: true
  globalize_accessors
  validate :validate_translates
  validates_associated :bdevent_works, :bdevent_products

  # 預告 或 正式 event
  EVENT_TYPES = %w(coming event)
  enum event_type: EVENT_TYPES
  FLEX_TYPES = {
    '全坑位' => 'full',
    '1/2坑位' => 'half'
  }

  accepts_nested_attributes_for :translations
  Translation.mount_uploader :banner, DefaultWithMetaUploader
  Translation.mount_uploader :coming_soon_image, DefaultWithMetaUploader
  Translation.mount_uploader :coupon_desc, DefaultWithMetaUploader

  mount_uploader :background, DefaultWithMetaUploader

  default_scope { order('priority DESC, created_at DESC') }

  scope :event_available, -> { event.enabled.where('starts_at <= :now and ends_at >= :now', now: Time.zone.now) }
  scope :coming_available, -> { coming.enabled.where('starts_at <= :now and ends_at >= :now', now: Time.zone.now) }

  def self.redis
    @redis ||= Redis::Namespace.new(:mobile_layout, redis: $redis)
  end

  def self.flex=(value)
    return unless value.in? FLEX_TYPES.values
    redis.set 'flex', value
  end

  def self.flex
    redis.get('flex')
  end

  def available?
    is_enabled && starts_at <= Time.zone.now && ends_at >= Time.zone.now
  end

  def kv_images
    images = bdevent_images.where(locale: I18n.locale)
    if I18n.locale != 'zh-TW' && images.map(&:file_url).join.empty?
      images = bdevent_images.where(locale: 'zh-TW')
    end
    images
  end

  def title
    translation_check(:title)
  end

  def desc
    translation_check(:desc)
  end

  def banner
    translation_check(:banner)
  end

  def coming_soon_image
    translation_check(:coming_soon_image)
  end

  def ticker
    translation_check(:ticker)
  end

  def coupon_desc
    translation_check(:coupon_desc)
  end

  protected

  def validate_translates
    obj = translation_for('zh-TW')
    errors.add(:title_zh_tw, 'zh-TW Title 不能是空白字元') if obj.title.empty?
    errors.add(:title_zh_tw, 'zh-TW Coming Image 不能是空白字元') if coming? && obj.coming_soon_image.url.empty?
    errors.add(:desc_zh_tw, 'zh-TW Desc 不能是空白字元') if event? && obj.desc.empty?
  end

  def translation_check(column)
    return unless [:title, :desc, :banner, :coming_soon_image, :ticker, :coupon_desc].include?(column)
    tmp = translation_for(I18n.locale).send(column)
    tmp = translation_for('zh-TW').send(column) unless tmp.present?
    tmp
  end
end
