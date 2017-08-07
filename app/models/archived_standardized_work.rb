# == Schema Information
#
# Table name: archived_standardized_works
#
#  id               :integer          not null, primary key
#  uuid             :string(255)
#  slug             :string(255)
#  original_work_id :integer
#  user_id          :integer
#  user_type        :string(255)
#  model_id         :integer
#  name             :string(255)
#  price_tier_id    :integer
#  featured         :boolean
#  print_image      :string(255)
#  image_meta       :json
#  created_at       :datetime
#  updated_at       :datetime
#  product_code     :string(255)
#  variant_id       :integer
#

class ArchivedStandardizedWork < ActiveRecord::Base
  include SharedWorkMethods
  include QiniuStoreImage

  friendly_id :uuid, use: [:slugged, :finders]

  mount_uploader :print_image, PrintUploader
  carrierwave_meta_composed :image_meta, :print_image, image_version: [:width, :height, :md5sum]
  preprocess_image :print_image, versions: %w(thumb)

  belongs_to :original_work, class_name: 'StandardizedWork'
  belongs_to :user, polymorphic: true
  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id
  belongs_to :price_tier
  has_one :deliver_error_collection, as: :workable
  has_many :previews, as: :work, dependent: :destroy
  has_many :output_files, as: :work, dependent: :destroy, class_name: 'WorkOutputFile'

  accepts_nested_attributes_for :previews, allow_destroy: true
  accepts_nested_attributes_for :output_files, allow_destroy: true

  default_scope { order('created_at desc') }

  delegate :description, to: :product, allow_nil: true, prefix: false

  validates :user_id, presence: true

  def archived?
    true
  end

  # 拋單用的 archived_attributes
  def china_archive_attributes
    {
      remote_product_key: product.remote_key,
      cover_image: nil,
      print_image: Region.global? ? qiniu_print_image_url : print_image.try(:url),
      order_image: Region.global? ? qiniu_order_image_url : order_image.try(:url),
      name: name || original_work.name,
    }
  end

  %w(order cover).each do |attr|
    define_method "#{attr}_image" do
      previews.find_by(key: "#{attr}-image").try(:image)
    end
  end

  def has_special_price?
    original_work.try(:has_special_price?)
  end

  def original_prices
    original_work.try(:original_prices)
  end

  def original_in_currency(currency)
    original_prices[currency] if original_prices.present?
  end

  def print_image
    output_files.find_by(key: 'print-image').try(:file) || super
  end

  def prices
    original_work.try(:prices) || (price_tier || product).prices
  end

  def published?
    original_work.try(:published?) || true
  end

  def is_public?
    published?
  end

  def product_code
    super || original_work.product_code
  end

  def cradle
    original_work.try(:cradle)
  end

  def cradle=(*)
  end
end
