# == Schema Information
#
# Table name: product_templates
#
#  id                    :integer          not null, primary key
#  product_model_id      :integer
#  store_id              :integer
#  price_tier_id         :integer
#  name                  :string(255)
#  placeholder_image     :string(255)
#  template_image        :string(255)
#  template_type         :integer
#  aasm_state            :string(255)
#  settings              :json
#  created_at            :datetime
#  updated_at            :datetime
#  image_meta            :json
#  works_count           :integer          default(0)
#  archived_works_count  :integer          default(0)
#  deleted_at            :datetime
#  bought_count          :integer          default(0)
#  special_price_tier_id :integer
#  description           :text
#

class ProductTemplate < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include AASM

  TEMPLATE_TYPES = %i(text_only photo_only text_and_photo).freeze
  TEXT_SETTING_KEYS = %w(font_name font_text max_font_size min_font_size
                         position_x position_y max_font_width rotation color).freeze

  acts_as_paranoid

  before_create :assign_price_tier

  belongs_to :product, class_name: 'ProductModel', foreign_key: :product_model_id
  has_one :category, through: :product
  belongs_to :price_tier
  belongs_to :store, touch: true
  belongs_to :special_price_tier, class_name: 'PriceTier', foreign_key: :special_price_tier_id

  has_many :works
  has_many :archived_works
  has_many :preview_composers, foreign_key: :template_id

  serialize :image_meta, Hashie::Mash.pg_json_serializer
  serialize :settings, Hashie::Mash.pg_json_serializer

  mount_uploader :placeholder_image, DefaultUploader
  mount_uploader :template_image, DefaultWithMetaUploader
  carrierwave_meta_composed :image_meta, :template_image, image_version: [:width, :height, :md5sum]

  scope :recent, -> { order('created_at DESC') }

  delegate :key, :name, :prices, to: :product, prefix: true
  delegate :name, to: :store, prefix: true

  accepts_nested_attributes_for :preview_composers

  enum template_type: TEMPLATE_TYPES

  validates :name, presence: true
  validates :product, presence: true
  validates :store, presence: true

  aasm do
    state :pending, initial: true
    state :published
    state :stopped

    event :publish do
      transitions from: :pending, to: :published
    end

    event :stop do
      transitions from: %i(pending published), to: :stopped
    end
  end

  def template_type_for_editor
    case template_type
    when 'text_only'
      %w(text)
    when 'photo_only'
      %w(photo)
    when 'text_and_photo'
      %w(photo text)
    end
  end

  def product_width
    (product.width * ImageService::MiniMagick::MM_TO_INCH * product.dpi).ceil
  end

  def product_height
    (product.height * ImageService::MiniMagick::MM_TO_INCH * product.dpi).ceil
  end

  def price(currency_code)
    prices[currency_code]
  end

  def prices
    (price_tier || product).prices
  end

  def special_price(currency_code)
    special_prices[currency_code]
  end

  def special_prices
    special_price_tier.try(:prices) || prices
  end

  def has_special_price?
    special_price('TWD') < price('TWD')
  end

  # template建立的sample work，專門用來當做在首頁顯示placeholder_image用
  def sample_work
    work = Work.find_by(name: 'ProductTemplate Sample', product_template_id: id)
    return work if work.present?
    Work.create(
      name: 'ProductTemplate Sample',
      product: product,
      product_template_id: id,
      work_type: 'is_private',
      user: store,
      uuid: UUIDTools::UUID.timestamp_create.to_s)
  end

  def update_sample_work_cover_image
    sample_work.update cover_image: template_image
  end

  def sample_placeholder_image_url
    sample_work.previews.find_by(key: 'order-image').try(:image).try(:url) || placeholder_image.url
  end

  def to_ecommerce_tracking
    {
      id: id,
      name: name,
      category: product_key,
      brand: store_name,
      price: prices[Region.default_currency]
    }
  end

  private

  def assign_price_tier
    self.price_tier_id = product.price_tier_id if price_tier_id.nil? && product.present?
  end
end
