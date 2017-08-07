# == Schema Information
#
# Table name: product_categories
#
#  id               :integer          not null, primary key
#  key              :string(255)
#  available        :boolean          default(FALSE), not null
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  category_code_id :string(255)
#  image            :string(255)
#  positions        :json             default(#<ProductCategory::Positions:0x007ff2747e00e0 @ios=1, @android=1, @website=1>)
#

class ProductCategory < ActiveRecord::Base
  include ActsAsTaggable
  include ActsAsPromotable
  include DelegateAccessors

  translates :name
  globalize_accessors

  accepts_nested_attributes_for :tags

  belongs_to :category_code, class_name: 'ProductCategoryCode'
  has_many :products, class_name: 'ProductModel', foreign_key: :category_id
  has_many :available_products, -> { available }, class_name: 'ProductModel', foreign_key: :category_id
  %w(works standardized_works).each do |works|
    has_many "available_website_product_#{works}".to_sym, -> { with_sellable_on_product('website') },
             through: :available_products, source: works
  end

  validates :key, presence: true, uniqueness: true

  scope :available, -> { where(available: true) }
  scope :with_available_product, -> { available.where(id: ProductModel.available.pluck(:category_id).uniq) }
  scope :with_sellable_on_product, (lambda do |platform|
    available.where(id: ProductModel.available.sellable_on(platform).pluck(:category_id).uniq)
  end)
  scope :ios_order, -> { order("cast(positions ->> 'ios' as int)") }
  scope :android_order, -> { order("cast(positions ->> 'android' as int)") }
  scope :website_order, -> { order("cast(positions ->> 'website' as int)") }
  scope :order_by, ->(platform) { send "#{platform}_order" }
  scope :available_products, -> { products.available }
  scope :recent, -> { order('created_at DESC') }
  scope :by_workables, -> (workables) { where(id: workables.map { |work| work.category.id }.uniq).recent }
  scope :by_product_templates, -> (product_templates) { where(id: product_templates.map { |t| t.category.id }.uniq).recent }

  delegate :code, :description, to: :category_code, allow_nil: true

  after_save :update_product_tag, if: :tag_ids_changed?

  mount_uploader :image, ProductCategoryUploader

  serialize :positions, Positions
  delegate_accessors :ios, :android, :website, to: :positions

  AVAILABLE_MODEL_KEYS = available.map(&:products).flatten.select(&:available).map(&:key).freeze

  # 更新Product Category时同步到Product Model上
  def update_product_tag
    removed_tag_ids = @changed_attributes[:tag_ids] - tag_ids
    products.each do |product|
      product.tag_ids = product.tag_ids + tag_ids - removed_tag_ids
      product.update_works_tag
    end
  end

  def friendly_name
    all? ? 'All' : name
  end

  def shop_work
    StandardizedWork
  end

  def work_list(model)
    return shop_work.with_available_product.with_sellable_on_product('website').is_public if all?
    works = shop_work.to_s.underscore.pluralize
    if model.is_a?(ProductModel)
      model.send(works).is_public.non_store
    else
      send("available_website_product_#{works}").is_public
    end
  end

  def all?
    key.blank?
  end

  def self.category_list
    # ProductCategory.new 代表[All] 选项
    ProductCategory.with_sellable_on_product('website').unshift(ProductCategory.new)
  end

  def set_platform_position(platform, position)
    fail ApplicationError unless platform.to_sym.in?(positions.attributes.keys)
    product_categories = ProductCategory.where.not(id: id).sort_by { |pm| pm.send(platform) }
    product_categories.each_with_index do |category, index|
      new_position = index + 1
      category.update("#{platform}": new_position) if new_position < position.to_i
      category.update("#{platform}": (new_position + 1)) if new_position >= position.to_i
    end
    update("#{platform}": position.to_i)
  end
end
