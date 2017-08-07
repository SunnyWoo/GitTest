# == Schema Information
#
# Table name: works
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  description             :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  cover_image             :string(255)
#  work_type               :integer          default(1)
#  finished                :boolean          default(FALSE)
#  feature                 :boolean          default(FALSE)
#  uuid                    :string(255)
#  print_image             :string(255)
#  model_id                :integer
#  artwork_id              :integer
#  image_meta              :json
#  slug                    :string(255)
#  impressions_count       :integer          default(0)
#  ai                      :string(255)
#  pdf                     :string(255)
#  price_tier_id           :integer
#  attached_cover_image_id :integer
#  template_id             :integer
#  deleted_at              :datetime
#  user_type               :string(255)
#  user_id                 :integer
#  application_id          :integer
#  product_template_id     :integer
#  cradle                  :integer          default(0)
#  share_text              :text
#  variant_id              :integer
#

class Work < ActiveRecord::Base
  acts_as_paranoid

  include SharedWorkMethods
  include PreviewsGenerator
  include Searchable
  include Searchable::WorkSearchable
  include WorkSaleCount
  include ProductWorkCode
  include HasAttachment
  include QiniuStoreImage
  include ActsAsTaggable
  include ActsAsStoreWork

  friendly_id :name, use: [:slugged, :finders]

  has_attachment :cover_image

  has_paper_trail
  is_impressionable counter_cache: true

  belongs_to :price_tier
  belongs_to :attached_cover_image, class_name: 'Attachment'
  belongs_to :template, class_name: 'WorkTemplate', foreign_key: 'template_id'
  belongs_to :application, class_name: 'Doorkeeper::Application', foreign_key: 'application_id'
  belongs_to :product_template, -> { try(:with_deleted) || all }, counter_cache: true

  # 手機傳錯 position 順序啦 QQ
  has_many :layers, -> { order('position ASC') }
  has_many :notes, as: :noteable
  has_many :reviews, -> { ordered }, as: :work
  has_many :archives, class_name: 'ArchivedWork', foreign_key: :original_work_id
  has_many :collection_works, as: :work

  accepts_nested_attributes_for :layers

  validates :name, presence: true
  validates :product, presence: true, associated: true
  validates :user, presence: true

  # redeem: 該商品只可以被兌換不會出現在購物車, shop
  WORK_TYPES = [:is_public, :is_private, :UNUSED, :redeem].freeze
  enum work_type: WORK_TYPES

  CRADLE_TYPES = %i(commandp b2b2c).freeze
  enum cradle: CRADLE_TYPES

  after_create :create_create_activity
  after_update :create_update_activity
  after_restore :create_restore_activity
  before_destroy :create_destroy_activity
  after_commit :enqueue_build_previews
  after_commit :log_print_image, if: :print_image_stored?

  scope :model_is, ->(model_name) { where(name: model_name) }
  scope :finished, -> { where(finished: true) }
  scope :featured, -> { is_public.where(feature: true) }
  scope :recent, ->(within) { where('created_at >= ?', within.ago) }
  scope :public_and_recent, ->(within) { where('works.work_type = 0 AND works.created_at >= ?', within.ago) }
  scope :by_designer, ->(designer) { designer.works }
  scope :by_design, ->(work) { Work.is_public.where(name: work.name) }
  scope :sorted, (lambda do |sort|
    case sort
    when 'new'     then order('created_at DESC')
    when 'random'  then order('RANDOM()')
    when 'popular' then order('impressions_count DESC')
    else order('created_at DESC')
    end
  end)

  delegate :username, :avatar, :display_name, to: :user, prefix: true
  delegate :key, :name, :available, :globalize_name, :price, to: :product, prefix: true
  delegate :id, :key, :name, to: :category, prefix: true
  delegate :active_promotions, to: :product

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  mount_uploader :cover_image, CoverImageUploader # 手機上傳 未何成
  mount_uploader :print_image, PrintUploader # 根據layer, 真的列印用
  mount_uploader :ai, RawUploader
  mount_uploader :pdf, RawUploader
  skip_callback :commit, :after, :remove_cover_image!
  skip_callback :commit, :after, :remove_print_image!
  carrierwave_meta_composed :image_meta, :cover_image, image_version: [:width, :height, :md5sum]
  carrierwave_meta_composed :image_meta, :print_image, image_version: [:width, :height, :md5sum]
  preprocess_image :cover_image, versions: %w(thumb shop)
  preprocess_image :print_image, versions: %w(thumb)

  def cover_image
    attached_cover_image.try(:file) || super
  end

  def model=(model)
    model = ProductModel.find_by('name = ?', model) if model.is_a? String
    self.product = model
  end

  # TODO: 當手機 app 都完成遷移時移除這個方法
  def spec_id=(spec_id)
    self.model_id = spec_id
  end

  # Public: 當使用者上傳完所有的圖層後將該作品狀態設為 finish, 並且寄送作品下載郵件
  #
  # Returns nothing.
  def finish!
    update_attribute('finished', true)
    create_activity(:finish)
  end

  # Public: 在後台上架作品時，根據 Crop 後的參數來新建立一個 crop version 圖片
  #
  # Returns nothing.
  def crop_image
    cover_image.cache_stored_file!
    cover_image.retrieve_from_cache!(cover_image.cache_name)
    cover_image.recreate_versions!(:crop)
  end

  def featured
    feature
  end

  alias_method :featured?, :featured

  def featured=(value)
    self.feature = value
  end

  def order_image
    previews.find_by(key: 'order-image').try(:image) || WorkUploader.new
  end

  # Public: 後台上傳作品後新增或更新 Layer ＆預設資訊
  #
  # Returns nothing.
  def build_layer(image: cover_image)
    return unless image.present?
    layer_params = { layer_type: :photo,
                     uuid: UUIDTools::UUID.timestamp_create.to_s,
                     scale_x: 0.5,
                     scale_y: 0.5,
                     position: 1 }
    case CARRIERWAVE_STORAGE
    when :file
      layer_params[:filtered_image] = image.file
      layer_params[:image] = image.file
    when :aws
      layer_params[:remote_filtered_image_url] = image.url
      layer_params[:remote_image_url] = image.url
    end
    if layers.count == 0
      layers.create!(layer_params)
    else
      layers[0].update_attributes(layer_params)
    end
  end

  # 拋單用的 archived_attributes
  def china_archive_attributes
    {
      remote_product_key: product.remote_key,
      cover_image: Region.global? ? qiniu_cover_image_shop_url : cover_image.try(:shop).try(:url), # 台灣要拋單到中國站時需要 QiniuStoreImage 的協助
      print_image: Region.global? ? qiniu_print_image_url : print_image.try(:url),
      name: name
    }
  end

  def recommend_works(limit = 6)
    limit = (limit || 6).to_i
    Work.is_public
        .where('id != ? AND model_id = ?', id, model_id).limit(limit)
        .order('random()')
  end

  def designer_works(limit)
    limit = limit.present? ? limit.to_i : 10
    user.try do |user|
      user.works.is_public.where.not(id: id).limit(limit)
    end
  end

  def series_works(limit)
    limit = limit.present? ? limit.to_i : 10
    Work.is_public.where(name: name).where.not(id: id).limit(limit)
  end

  def created_channel
    activities.find_by(key: :create).try { |activity| activity.source[:channel] }
  end

  def created_os_type
    activities.find_by(key: :create).try { |activity| activity.source[:os_type] }
  end

  def archived_attributes
    {
      model_id: model_id,
      variant_id: variant_id,
      cover_image: cover_image.file,
      work_order_image: order_image.file,
      application_id: application_id,
      layers_attributes: layers.root.map(&:archived_attributes),
      user_type: user_type,
      user_id: user_id,
      name: name,
      product_code: product_code,
      product_template_id: product_template_id
    }
  end

  def create_archive
    archives.create!(archived_attributes)
  end

  def archived?
    is_public?
  end

  def last_archive
    create_archive
  end

  # TODO: 轉移完畢/沒問題後可以移除我
  def standardized_attributes
    {
      uuid: uuid,
      user_type: user_type,
      user_id: user_id,
      name: name,
      model_id: model_id,
      price_tier_id: price_tier_id,
      featured: featured,
      print_image: print_image,
      previews_attributes: previews.map(&:archived_attributes)
    }
  end

  # TODO: 轉移完畢/沒問題後可以移除我
  def create_standardized_work
    StandardizedWork.create(standardized_attributes)
  end

  def prices
    if is_private? && product_template.present?
      product_template.special_prices
    elsif is_private? && product.customized_special_price?
      product.customized_special_price_tier.prices
    else
      (price_tier || product).prices
    end
  end

  def original_prices
    if product_template.present?
      product_template.prices
    else
      product.try(:prices)
    end
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

  def to_ecommerce_tracking
    {
      id: uuid,
      name: name,
      category: product_key,
      brand: 'User',
      price: price_in_currency(Region.default_currency)
    }
  end

  private

  def create_create_activity
    create_activity(:create)
  end

  def create_update_activity
    create_activity(:update, version_id: versions.last.try(:id))
  end

  def create_destroy_activity
    create_activity(:destroy)
  end

  def create_restore_activity
    create_activity(:restore)
  end

  def log_print_image
    create_activity('log_print_image', url: print_image.url)
  end

  def enqueue_build_previews
    enqueue_build_previews_by_cover_image if cover_image_stored?
    return if disable_build_order_image?
    enqueue_build_previews_by_print_image if print_image_stored?
  end
end
