# == Schema Information
#
# Table name: bdevent_redeems
#
#  id                :integer          not null, primary key
#  code              :string(255)
#  bdevent_id        :integer
#  parent_id         :integer
#  children_count    :integer          default(0)
#  usage_count       :integer          default(0)
#  usage_count_limit :integer          default(-1)
#  product_model_ids :integer          default([]), is an Array
#  order_ids         :integer          default([]), is an Array
#  is_enabled        :boolean          default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#  work_ids          :integer          default([]), is an Array
#

class BdeventRedeem < ActiveRecord::Base
  include ActsAsIsEnabled

  belongs_to :bdevent
  belongs_to :parent, class_name: 'BdeventRedeem', counter_cache: :children_count
  has_many :children, class_name: 'BdeventRedeem', foreign_key: :parent_id

  validates :code, presence: true, uniqueness: true
  validate :validates_usage_count_should_be_less_than_limit
  validate :validates_unique_coupon_should_not_be_event

  before_validation :generate_code, :upcase_code
  after_create :create_unique_coupon_children
  after_save :increase_usage_count, if: :order_ids_changed?

  def self.generate_code
    loop do
      code = SecureRandom.hex(3).upcase
      return code unless BdeventRedeem.exists?(code: code)
    end
  end

  def quantity
    @quantity ||= [children.size, 1].max
  end

  # 設定數量, 會自動調整為 >= 1 的整數
  def quantity=(value)
    @quantity = [value.to_i, 1].max
  end

  def can_use?
    if reach_limit?
      errors.add(:base, 'Code is used')
      false
    elsif !is_enabled?
      errors.add(:base, 'Code is disable')
      false
    else
      true
    end
  end

  def no_limit?
    usage_count_limit == -1
  end

  def reach_limit?
    usage_count_limit != -1 && usage_count >= usage_count_limit
  end

  def used?
    orders.size > 0
  end

  def orders
    Order.where(id: order_ids)
  end

  def product_models
    ProductModel.where(id: product_model_ids)
  end

  def works
    Work.where(id: work_ids)
  end

  private

  def generate_code
    self.code = code.present? ? code : self.class.generate_code
  end

  def create_unique_coupon_children
    return if quantity == 1
    disable
    quantity.times do
      children.create(child_attributes.merge(usage_count_limit: 1))
    end
  end

  def upcase_code
    code.upcase!
  end

  CHILD_ATTRIBUTES = %i(bdevent_id product_model_ids).freeze

  def child_attributes
    CHILD_ATTRIBUTES.each_with_object({}) do |key, hash|
      hash[key] = send(key)
    end
  end

  def validates_usage_count_should_be_less_than_limit
    return unless usage_count_limit != -1 && usage_count > usage_count_limit
    errors.add(:usage_count_limit, :invalid_usage_count_limit)
  end

  def validates_unique_coupon_should_not_be_event
    return unless quantity > 1 && usage_count_limit != 1
    errors.add(:usage_count_limit, :child_event_coupon)
  end

  def increase_usage_count
    BdeventRedeem.find(id).increment!(:usage_count)
    BdeventRedeem.find(id).parent.increment!(:usage_count) if parent.present?
  end
end
