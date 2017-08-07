# == Schema Information
#
# Table name: standardized_works
#
#  id                :integer          not null, primary key
#  uuid              :string(255)
#  user_id           :integer
#  user_type         :string(255)
#  model_id          :integer
#  name              :string(255)
#  slug              :string(255)
#  aasm_state        :string(255)
#  price_tier_id     :integer
#  featured          :boolean          default(FALSE), not null
#  print_image       :string(255)
#  image_meta        :json
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  impressions_count :integer          default(0)
#  cradle            :integer          default(0)
#  bought_count      :integer          default(0)
#  content           :text
#  variant_id        :integer
#

class StandardizedWork < ActiveRecord::Base
  include ActsAsTaggable
  include ActsAsPromotable
  include ActsAsPriced
  include SharedWorkMethods
  include AASM
  include Searchable
  include Searchable::WorkSearchable
  include ProductWorkCode
  include PreviewsGenerator
  include QiniuStoreImage
  # include ActsAsTaggable

  attr_accessor :build_previews, :is_build_print_image

  acts_as_paranoid
  friendly_id :name, use: [:slugged, :finders]
  is_impressionable counter_cache: true

  mount_uploader :print_image, PrintUploader
  carrierwave_meta_composed :image_meta, :print_image, image_version: [:width, :height, :md5sum]
  preprocess_image :print_image, versions: %w(thumb)
  strip_attributes only: %w(name slug)

  belongs_to :price_tier
  has_many :output_files, as: :work, dependent: :destroy, class_name: 'WorkOutputFile'
  has_many :archives, class_name: 'ArchivedStandardizedWork', foreign_key: :original_work_id
  has_many :collection_works, as: :work
  has_many :reviews, -> { ordered }, as: :work

  validates :product, :user, :name, presence: true

  delegate :id, to: :category, prefix: true
  delegate :avatar, to: :user, prefix: true
  delegate :description, to: :product, allow_nil: true, prefix: false

  accepts_nested_attributes_for :previews, allow_destroy: true
  accepts_nested_attributes_for :output_files, allow_destroy: true

  scope :is_public, -> { published }
  scope :find_id_or_slug, ->(id) { where('standardized_works.id = ? or standardized_works.slug = ?', (Integer(id) rescue nil), id) }
  scope :non_store, -> { commandp.where.not(user_type: 'Store') }

  after_commit :enqueue_build_previews_by_print_image, if: :build_previews_required?
  after_save :enqueue_build_print_image, if: :build_print_image_required?

  enum cradle: Work::CRADLE_TYPES

  aasm do
    state :draft, initial: true
    state :published
    state :pulled

    event :publish do
      transitions from: [:draft, :pulled], to: :published
    end

    event :pull do
      transitions from: :published, to: :pulled
    end
  end

  def print_image_aid=(aid)
    self.print_image = Attachment.find_by_aid!(aid).file
  end

  def print_image
    output_files.find_by(key: 'print-image').try(:file) || super
  end

  def print_image=(image)
    output_files.find_by(key: 'print-image').try do |output_file|
      output_file.update file: image
    end or super
  end

  def print_image?
    print_image.present?
  end

  def archived_attributes
    {
      user_id: user_id,
      user_type: user_type,
      name: name,
      model_id: model_id,
      variant_id: variant_id,
      price_tier_id: price_tier_id,
      featured: featured,
      print_image: print_image,
      previews_attributes: previews.map(&:archived_attributes),
      output_files_attributes: output_files.map(&:archived_attributes),
      product_code: product_code
    }
  end

  def china_archive_attributes
    {
      remote_product_key: product.remote_key,
      cover_image: nil,
      print_image: Region.global? ? qiniu_print_image_url : print_image.try(:url),
      order_image: Region.global? ? qiniu_order_image_url : order_image.try(:url),
      name: name
    }
  end

  def create_archive
    archives.create!(archived_attributes)
  end

  def archived?
    false
  end

  def last_archive
    archives.first || create_archive
  end

  def need_indexed?
    published? && product_available
  end

  %w(order cover).each do |attr|
    define_method "#{attr}_image" do
      previews.find_by(key: "#{attr}-image").try(:image)
    end
  end

  def prices
    (price_tier || product).prices
  end

  def original_prices
    product.prices
  end

  def price_in_currency(currency)
    prices[currency]
  end

  def original_price_in_currency(currency)
    original_prices[currency]
  end

  def has_special_price?
    price_in_currency('TWD') < original_price_in_currency('TWD')
  end

  def work_type
    'is_public'
  end

  def is_public?
    published?
  end

  def recommend_works(limit = 6)
    limit = (limit || 6).to_i
    self.class.published
        .where('id != ? AND model_id = ?', id, model_id).limit(limit)
        .order('random()')
  end

  def designer_works(limit)
    limit = limit.present? ? limit.to_i : 10
    user.try do |user|
      user.standardized_works.published.where.not(id: id).limit(limit)
    end
  end

  def series_works(limit)
    limit = limit.present? ? limit.to_i : 10
    self.class.published.where(name: name).where.not(id: id).limit(limit)
  end

  def ordered_previews
    previews
  end

  def build_previews_required?
    build_previews.to_b && print_image_is_an_image?
  end

  def build_print_image_required?
    is_build_print_image.to_b && print_image_is_an_image?
  end

  def redeem?
    false
  end

  def output_files_for_print_image
    output_files.where(key: 'print-image')
  end

  def output_files_without_print_image
    output_files.where.not(key: 'print-image')
  end

  def to_ecommerce_tracking
    {
      id: uuid,
      name: name,
      category: product_key,
      brand: user_display_name,
      price: price_in_currency(Region.default_currency)
    }
  end
end
