# == Schema Information
#
# Table name: product_models
#
#  id                                        :integer          not null, primary key
#  name                                      :string(255)
#  description                               :text
#  created_at                                :datetime
#  updated_at                                :datetime
#  available                                 :boolean          default(FALSE)
#  slug                                      :string(255)
#  category_id                               :integer
#  key                                       :string(255)
#  dir_name                                  :string(255)
#  placeholder_image                         :string(255)
#  price_tier_id                             :integer
#  design_platform                           :json
#  customize_platform                        :json
#  customized_special_price_tier_id          :integer
#  material                                  :string(255)
#  weight                                    :float
#  enable_white                              :boolean          default(FALSE)
#  auto_imposite                             :boolean          default(FALSE), not null
#  factory_id                                :integer
#  extra_info                                :json
#  aasm_state                                :string(255)
#  positions                                 :json             default(#<ProductModel::Positions:0x007ff27a813688 @ios=1, @android=1, @website=1>)
#  remote_key                                :string(255)
#  watermark                                 :string(255)
#  print_image_mask                          :string(255)
#  craft_id                                  :integer
#  spec_id                                   :integer
#  material_id                               :integer
#  code                                      :string(255)
#  external_code                             :string(255)
#  enable_composite_with_horizontal_rotation :boolean          default(FALSE)
#  create_order_image_by_cover_image         :boolean          default(FALSE)
#  enable_back_image                         :boolean          default(FALSE)
#  profit_id                                 :integer
#

class ProductModel < ActiveRecord::Base
  include ActsAsTaggable
  include ActsAsPromotable
  include HasPromotionPrice
  include ActsAsPriced
  include HasGoogleCalendar
  include AASM
  extend FriendlyId
  attr_accessor :warning
  include DelegateAccessors
  include UploadInventory
  include VariantBuilder

  EXTRA_INFO_ATTRIBUTES = [
    :width, :height, :dpi, :background_image, :overlay_image,
    :shape, :alignment_points, :padding_top, :padding_right,
    :padding_bottom, :padding_left, :background_color
  ].freeze

  serialize :design_platform, Hashie::Mash.pg_json_serializer
  serialize :customize_platform, Hashie::Mash.pg_json_serializer
  serialize :extra_info, ExtraInfo
  serialize :positions, Positions
  delegate_accessors(*EXTRA_INFO_ATTRIBUTES, to: :extra_info)
  delegate_accessors :ios, :android, :website, to: :positions

  friendly_id :friendly_name, use: [:slugged, :finders]
  translates :name, :description, :short_name
  globalize_accessors
  mount_uploader :placeholder_image, DefaultUploader
  mount_uploader :print_image_mask, DefaultUploader
  mount_uploader :watermark, DefaultUploader
  mount_uploader :background_image, DefaultUploader, serialize_to: :extra_info
  mount_uploader :overlay_image, ProductModelOverlayUploader, serialize_to: :extra_info
  strip_attributes only: %i(key slug name)
  has_paper_trail

  belongs_to :price_tier
  belongs_to :customized_special_price_tier, class_name: 'PriceTier'
  belongs_to :category, class_name: 'ProductCategory'
  belongs_to :craft, class_name: 'ProductCraft'
  belongs_to :spec, class_name: 'ProductSpec'
  belongs_to :product_material, class_name: 'ProductMaterial', foreign_key: :material_id
  belongs_to :factory
  belongs_to :profit, class_name: 'PriceTier', foreign_key: 'profit_id'
  has_one :imposition, -> { production }, foreign_key: :model_id
  has_many :demo_impositions, -> { demo }, foreign_key: :model_id, class_name: 'Imposition'
  has_many :currencies, as: :payable
  has_many :works, foreign_key: :model_id
  has_many :standardized_works, foreign_key: :model_id
  has_many :preview_composers, foreign_key: :model_id
  has_many :picking_materials, foreign_key: :model_id
  has_many :templates, class_name: 'WorkTemplate', foreign_key: :model_id
  has_many :print_items, foreign_key: :model_id
  has_many :product_templates
  has_many :description_images, class_name: 'ProductModel::DescriptionImage', foreign_key: :product_id
  has_many :product_option_types, dependent: :destroy, foreign_key: :product_id, inverse_of: :product
  has_many :option_types, through: :product_option_types
  has_many :variants, dependent: :destroy, foreign_key: :product_id

  accepts_nested_attributes_for :currencies
  accepts_nested_attributes_for :picking_materials, allow_destroy: true
  accepts_nested_attributes_for :description_images, allow_destroy: true

  validates :name, :category_id, presence: true
  validates :key, uniqueness: { scope: :category_id }
  validates :slug, uniqueness: true
  validates :factory, presence: true
  validates :code, uniqueness: true

  scope :available, -> { where(available: true, aasm_state: :customer) }
  scope :staff_available, -> { where(available: true) }
  scope :ios_order, -> { order("cast(positions ->> 'ios' as int)") }
  scope :android_order, -> { order("cast(positions ->> 'android' as int)") }
  scope :website_order, -> { order("cast(positions ->> 'website' as int)") }
  scope :order_by, ->(platform) { send "#{platform}_order" }
  scope :sellable_on, (lambda do |platform|
    where('design_platform ->> :platform = :result', platform: platform, result: 'true')
  end)
  scope :customizable_on, (lambda do |platform|
    where('customize_platform ->> :platform = :result', platform: platform, result: 'true')
  end)
  scope :all_on, (lambda do |platform|
    where('design_platform ->> :platform = :result OR customize_platform ->> :platform = :result',
          platform: platform, result: 'true')
  end)
  scope :platform_order_with_category, ->(platform){
    joins(:category).order("cast(product_categories.positions ->> '#{platform}' as int), cast(product_models.positions ->> '#{platform}' as int)")
  }
  scope :store_on_platform, ->(platform, store){
    send("#{store}_on", platform)
  }
  scope :with_external_code, -> { where.not(external_code: [nil, '']) }
  scope :recent, -> { order('created_at DESC') }
  scope :by_workables, -> (workables) { where(id: workables.map(&:model_id).uniq).recent }
  scope :by_product_templates, -> (product_templates) { where(id: product_templates.map(&:product_model_id).uniq).recent }

  before_validation :generate_code
  after_save :touch_work
  after_save :check_print_image_mask_size, if: :print_image_mask_changed?
  after_update :push_google_calendar_for_update, if: -> { enable_google_calendar? && (customize_platform_changed? || design_platform_changed?) }
  after_create :push_google_calendar_for_create, if: :enable_google_calendar?
  after_save :update_works_tag, if: :tag_ids_changed?
  before_save :check_platforms
  delegate :code, :name, to: :category, allow_nil: true, prefix: true
  delegate :code, to: :product_material, allow_nil: true, prefix: true
  delegate :code, to: :craft, allow_nil: true, prefix: true
  delegate :code, to: :spec, allow_nil: true, prefix: true
  delegate :name, to: :factory, allow_nil: true, prefix: true

  PLATFORM_TO_SLUG_MAPPING = {
    'design_platform'    => '設計師',
    'customize_platform' => '客製化'
  }.freeze

  def self.platforms
    { ios: false, android: false, website: false }
  end

  def self.model_list(category_key = nil)
    categories = ProductCategory.available
    categories = categories.where(key: category_key) if category_key.present?
    categories.reduce([]) do |result, category|
      result + category.products.available.to_a
    end.unshift(wildcard)
  end

  def self.default
    wildcard_or_find_by('all-cases')
  end

  def self.wildcard
    WildcardProductModel.instance
  end

  def self.wildcard_or_find_by(id)
    id == wildcard.slug ? wildcard : available.find(id)
  end

  def self.generate_code
    loop do
      code = [*'0'..'9', *'A'..'Z'].sample(4).join
      return code unless exists?(code: code)
    end
  end

  def self.update_works_tag(id, added_tag_ids, removed_tag_ids)
    product = ProductModel.find_by_id(id)
    return if product.blank?
    (product.works.is_public.to_a + product.standardized_works.to_a).each do |work|
      work.tag_ids = work.tag_ids + added_tag_ids - removed_tag_ids
    end
  end

  aasm do
    state :customer, initial: true
    state :staff
  end

  def price_in_currency(currency)
    price(currency)
  end

  def price(currency)
    if price_tier
      price_tier.prices[currency]
    else
      currencies.find_by(code: currency).try(:price) # 向前相容所需
    end
  end

  def prices
    if price_tier
      price_tier.prices
    else
      # 向前相容所需
      currencies.each_with_object({}) do |currency, hash|
        hash[currency.code] = currency.price
      end
    end
  end

  def customized_special_price(currency)
    if customized_special_price?
      customized_special_prices[currency]
    else
      price(currency)
    end
  end

  def customized_special_prices
    customized_special_price_tier.try(:prices) || prices
  end

  def customized_special_price?
    customized_special_price_tier.present?
  end

  def build_currencies_set
    CurrencyType.find_each do |type|
      currencies.build(name: type.name, code: type.code)
    end
  end

  def build_missing_currencies_set
    CurrencyType.where(code: currencies.missing_currencies).find_each do |type|
      currencies.build(name: type.name, code: type.code)
    end
  end

  def friendly_name
    name.to_s
  end

  def globalize_name
    translations.map(&:name).join('|')
  end

  def touch_work
    return unless available_changed?
    works.find_each(&:touch)
    standardized_works.find_each(&:touch)
  end

  def enqueue_imposite_and_upload
    items = PrintItem.includes(:order_item).where(aasm_state: 'pending', model_id: id).select { |pi| pi.order.approved? && pi.order.paid? }
    items.each(&:upload!)
    Imposition::Spliter.perform_async(factory.id, id, items.map(&:id))
  end

  def dpi_width
    width / 25.4 * dpi
  end

  def dpi_height
    height / 25.4 * dpi
  end

  class WildcardProductModel
    include Singleton

    def id
      nil
    end

    def name
      'All'
    end

    def friendly_name
      'All'
    end

    def works
      Work.with_available_product
    end

    def slug
      'all-cases'
    end

    def key
      'all'
    end
  end

  def set_platform_position(platform, position)
    fail ApplicationError unless platform.to_sym.in?(positions.attributes.keys)
    product_models = self.class.where(category_id: category_id).where.not(id: id).sort_by { |pm| pm.send(platform) }
    product_models.each_with_index do |pro_model, index|
      new_position = index + 1
      pro_model.update("#{platform}": new_position) if new_position < position.to_i
      pro_model.update("#{platform}": (new_position + 1)) if new_position >= position.to_i
    end
    update("#{platform}": position.to_i)
  end

  def remote?
    remote_key.present?
  end

  def product_cmsc_code
    "#{category_code}#{product_material_code}#{craft_code}#{spec_code}"
  end

  def product_code
    "#{product_cmsc_code}#{code}"
  end

  # 更新Product Model时同步到设计师作品上
  def update_works_tag
    removed_tag_ids = @changed_attributes[:tag_ids] - tag_ids
    UpdateWorkTagWorker.perform_async(id, tag_ids, removed_tag_ids)
  end

  def external_production?
    external_code.present?
  end

  def active_promotions
    (
      promotions.item_level.available +
      category.promotions.item_level.available
    ).uniq.sort_by(&:begins_at)
  end

  # implement interface for HasPromotionPrice
  def special_prices
    customized_special_prices || prices
  end

  def original_prices
    prices
  end

  def read_attribute(attr_name, *args, &block)
    if attr_name.in? EXTRA_INFO_ATTRIBUTES
      extra_info[attr_name]
    else
      super
    end
  end

  private

  def push_google_calendar_for_update
    changed_hash = {}
    PLATFORM_TO_SLUG_MAPPING.each do |type, _|
      changed_hash[type] = changes[type][1].select { |k, v| v != changes[type][0][k] } unless changes[type].nil? || changes[type][0].nil?
    end

    push_google_calendar_event(changed_hash)
  end

  def push_google_calendar_for_create
    changed_hash = {}
    PLATFORM_TO_SLUG_MAPPING.each do |type, _|
      changed_hash[type] = send(type).select { |_, v| v == true }
    end

    push_google_calendar_event(changed_hash, false)
  end

  def push_google_calendar_event(platform_list, is_changed = true)
    changed_status = is_changed ? '將' : '新增'

    default_str = "#{Admin.current_admin.account_name} #{changed_status} #{name}"

    platform_status_content = []

    platform_list.each do |key, value|
      next if value.blank?
      value.each do |k, v|
        status = v ? '上架了' : '下架了'
        platform_status_content << "[#{PLATFORM_TO_SLUG_MAPPING[key]}]#{status} #{k}"
      end
    end
    GoogleCalendarProductModelEventWorker.perform_async("#{default_str} #{platform_status_content.join('、')}。", Time.zone.now)
  end

  # Make sure design_platform and customize_platform have default attributes and
  # the values are boolean
  def check_platforms
    default_platform_attrs = ProductModel.platforms.stringify_keys
    self.design_platform = default_platform_attrs.merge(booleanize_hashs(design_platform))
    self.customize_platform = default_platform_attrs.merge(booleanize_hashs(customize_platform))
  end

  def booleanize_hashs(hash)
    hash.each { |k, v| hash[k] = v.to_b if v.respond_to?(:to_b) }
  end

  # DELETE: after enable work spec
  def check_print_image_mask_size
    return if print_image_mask.blank?
    expect_width = (width / 25.4 * dpi).to_i
    expect_height = (height / 25.4 * dpi).to_i
    # FIXME: private API may broken in the future, but we really need it at this time
    actual_width, actual_height = print_image_mask.send(:get_dimensions)
    return if actual_width == expect_width && actual_height == expect_height
    self.warning = "上傳的遮罩圖大小為 #{actual_width}x#{actual_height}, 但產品圖的大小為 #{expect_width}x#{expect_height}"
  end

  def generate_code
    self.code ||= self.class.generate_code
  end
end
