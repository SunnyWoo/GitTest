# == Schema Information
#
# Table name: archived_works
#
#  id                  :integer          not null, primary key
#  original_work_id    :integer
#  artwork_id          :integer
#  model_id            :integer
#  cover_image         :string(255)
#  print_image         :string(255)
#  fixed_image         :string(255)
#  image_meta          :json
#  created_at          :datetime
#  updated_at          :datetime
#  slug                :string(255)
#  uuid                :string(255)
#  ai                  :string(255)
#  pdf                 :string(255)
#  prices              :json
#  user_type           :string(255)
#  user_id             :integer
#  application_id      :integer
#  name                :string(255)
#  product_code        :string(255)
#  product_template_id :integer
#  variant_id          :integer
#

class ArchivedWork < ActiveRecord::Base
  include SharedWorkMethods
  include PreviewsGenerator
  include QiniuStoreImage
  include ActsAsStoreWork

  friendly_id :uuid, use: [:slugged, :finders]

  attr_accessor :work_order_image, :delivery_order
  belongs_to :original_work, class_name: 'Work'
  belongs_to :application, class_name: 'Doorkeeper::Application', foreign_key: 'application_id'
  belongs_to :product_template, -> { try(:with_deleted) || all }, counter_cache: true

  has_one :deliver_error_collection, as: :workable
  has_many :layers, -> { ordered }, class_name: 'ArchivedLayer', foreign_key: :work_id, dependent: :destroy

  validates :user_id, presence: true
  before_create :store_prices, unless: :delivery_order
  after_save :touch_order_item, if: :image_changed?
  after_create :create_order_image_preview, if: :work_order_image
  after_commit :enqueue_build_print_image, on: :create, unless: :delivery_order
  after_commit :enqueue_build_previews
  after_commit :log_print_image, if: :print_image_stored?

  accepts_nested_attributes_for :layers

  mount_uploader :cover_image, CoverImageUploader # 手機上傳 未何成
  mount_uploader :print_image, PrintUploader # 根據layer, 真的列印用
  mount_uploader :fixed_image, PrintUploader
  mount_uploader :ai, RawUploader
  mount_uploader :pdf, RawUploader
  carrierwave_meta_composed :image_meta, :cover_image, image_version: [:width, :height, :md5sum]
  carrierwave_meta_composed :image_meta, :print_image, image_version: [:width, :height, :md5sum]
  carrierwave_meta_composed :image_meta, :fixed_image, image_version: [:width, :height, :md5sum]
  preprocess_image :cover_image, versions: %w(thumb)
  preprocess_image :print_image, versions: %w(thumb)
  preprocess_image :fixed_image, versions: %w(thumb)

  delegate :key, :name, to: :category, prefix: true
  delegate :featured?, :tags, to: :original_work

  def description
    ''
  end

  def archived?
    true
  end

  def is_public?
    false
  end

  def price_in_currency(currency)
    prices[currency]
  end

  def has_special_price?
    original_work.try(:has_special_price?)
  end

  def original_prices
    original_work.try(:original_prices) || product.try(:prices)
  end

  def original_price_in_currency(currency)
    original_prices[currency] if original_prices.present?
  end

  alias_method :original_print_image, :print_image

  def print_image
    fixed_image.present? ? fixed_image : super
  end

  def order_image
    previews.find_by(key: 'order-image').try(:image) || WorkUploader.new
  end

  def log_print_image
    create_activity('log_print_image', url: print_image.url)
  end

  def touch_order_item
    order_items.all.find_each(&:touch)
  end

  def prices
    super || original_work.try(:prices)
  end

  def create_order_image_preview
    previews.create(key: 'order-image', image: work_order_image)
  end

  def work_type
    'is_private'
  end

  # 拋單用的 archived_attributes
  def china_archive_attributes
    {
      remote_product_key: product.remote_key,
      cover_image: Region.global? ? qiniu_cover_image_shop_url : cover_image.try(:shop).try(:url), # 台灣要拋單到中國站時需要 QiniuStoreImage 的協助
      print_image: Region.global? ? qiniu_print_image_url : print_image.try(:url),
      name: name || original_work.name
    }
  end

  def product_code
    super || original_work.product_code
  end

  protected

  def image_changed?
    %w(print_image cover_image ai pdf).map do |attr|
      send("#{attr}_changed?")
    end.include? true
  end

  # 儲存當下單價 (不計入數量)
  def store_prices
    self.prices = original_work.try(:prices)
  end

  def enqueue_build_previews
    if disable_build_order_image?
      return unless cover_image_stored?
      enqueue_build_previews_by_cover_image
    else
      return unless print_image_stored?
      enqueue_build_previews_by_print_image
    end
  end

  def cradle
    original_work.try(:cradle)
  end

  def cradle=(*)
  end
end
