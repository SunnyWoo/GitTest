# == Schema Information
#
# Table name: coupons
#
#  id                       :integer          not null, primary key
#  title                    :string(255)
#  code                     :string(255)
#  expired_at               :date
#  created_at               :datetime
#  updated_at               :datetime
#  price_tier_id            :integer
#  parent_id                :integer
#  children_count           :integer          default(0)
#  discount_type            :string(255)
#  percentage               :decimal(8, 2)
#  condition                :string(255)
#  threshold_id             :integer
#  product_model_ids        :integer          default([]), is an Array
#  apply_target             :string(255)
#  usage_count              :integer          default(0)
#  usage_count_limit        :integer          default(-1)
#  begin_at                 :date
#  is_enabled               :boolean          default(TRUE)
#  auto_approve             :boolean          default(FALSE)
#  designer_ids             :integer          default([]), is an Array
#  work_gids                :text             default([]), is an Array
#  user_usage_count_limit   :integer          default(-1)
#  base_price_type          :string(255)
#  apply_count_limit        :integer
#  product_category_ids     :integer          default([]), is an Array
#  bdevent_id               :integer
#  settings                 :hstore           default({})
#  is_free_shipping         :boolean          default(FALSE)
#  is_not_include_promotion :boolean          default(FALSE)
#

class Coupon < ActiveRecord::Base
  include ActsAsIsEnabled
  include HasDiscountFormula
  include ActsAsAdjustmentSource

  store_accessor :settings, :code_type, :code_length, :quantity
  has_discount_formula :discount_parameters

  CODE_TYPES = %w(base number alphabet).freeze
  CODE_BASE = (('A'..'Z').to_a + ('0'..'9').to_a).freeze
  CODE_NUMBER = ('0'..'9').to_a.freeze
  CODE_ALPHABET = ('A'..'Z').to_a.freeze

  belongs_to :price_tier
  belongs_to :parent, class_name: 'Coupon', counter_cache: :children_count
  belongs_to :threshold, class_name: 'PriceTier'
  belongs_to :bdevent
  has_many :children, class_name: 'Coupon', foreign_key: :parent_id
  has_many :currencies, as: :payable
  has_many :orders
  has_many :notices, class_name: 'CouponNotice'
  has_many :coupon_rules

  validates :title, :code, :begin_at, :expired_at, :user_usage_count_limit, :base_price_type, presence: true
  # fixed:固定折扣金額 percentage:固定折扣比例 pay:固定結單金額
  validates :discount_type, inclusion: %w(fixed percentage pay none)
  validates :condition, inclusion: %w(none simple rules)
  validates :base_price_type, inclusion: %w(original special)
  validates_length_of :coupon_rules, maximum: 2
  validate :validates_code_should_be_uniqueness_in_the_range, if: :code_changed?
  validate :validates_unique_coupon_should_not_be_event
  validate :validates_price_tier_should_be_present_if_discount_type_is_fixed
  validate :validates_percentage_should_be_valid_if_discount_type_is_percentage
  validate :validates_usage_count_should_be_less_than_limit, on: :create
  validate :validates_begin_at_should_not_before_today, unless: :child?, on: :create
  validate :validates_expired_at_should_not_before_today
  validate :validates_by_expired_at_on_update, on: :update
  validates_with SameModelCouponRulesValidator

  before_validation :set_default_range, :generate_code, :upcase_code
  after_create :enqueue_create_unique_coupon_children
  after_update :update_unique_coupon_children

  scope :root, -> { where(parent_id: nil) }
  scope :leaves, -> { where(children_count: 0) }
  scope :auto_approved, -> { where(auto_approve: true) }
  scope :expired, -> { where('expired_at < ?', Time.zone.now) }
  scope :expired_at_yesterday, -> { where(expired_at: Time.zone.yesterday) }

  accepts_nested_attributes_for :currencies, :coupon_rules

  # type should be [base, number, alphabet]
  # length min is 6
  def self.generate_code(type = 'base', length = 6)
    length = length.to_i
    fail ApplicationError, "code_type should in (#{CODE_TYPES.join(', ')})" unless CODE_TYPES.include?(type)
    fail ApplicationError, "code_length should in 6..20 })" unless (6..20).to_a.include?(length)
    loop do
      code = ''
      length.times { code += const_get("CODE_#{type.upcase}").sample }
      return code unless Coupon.exists?(code: code)
    end
  end

  def self.available_in_range(begin_at, expired_at)
    where('(:begin_at >= begin_at AND :begin_at <= expired_at) OR
           (:expired_at >= begin_at AND :expired_at <= expired_at) OR
           (begin_at >= :begin_at AND begin_at <= :expired_at) OR
           (expired_at >= :begin_at AND expired_at <= :expired_at)',
          begin_at: begin_at,
          expired_at: expired_at)
  end

  def quantity
    [super.to_i, children.size, 1].max
  end

  # TODO: 不需要了, 可以移除?
  def build_currencies_set
    CurrencyType.find_each do |type|
      currencies.build(name: type.name, code: type.code)
    end
  end

  def leaf?
    children_count == 0
  end

  def group?
    children.size > 0
  end

  def root?
    parent.nil?
  end

  def is_used?
    usage_count > 0
  end

  def can_use?(user = nil, order = nil)
    CouponCheckService.new(self, user: user, order: order).pass?
  end

  def forbidden_scope?(user, order)
    return false unless order.is_a?(Order) # No Order Information, unable to make judgement
    coupon = root? ? self : parent
    CouponForbiddenEvent.active.any? { |e| e.blocking?(coupon, order, user) }
  end

  # 傳入  work.to_gid_param
  # redeem_work是单一优惠，不会有复合优惠条件
  def can_use_with_redeem_work?(gid_param, user, order = nil)
    CouponCheckService.new(self, user: user, order: order).pass_with_redeem_work?(gid_param)
  end

  # 此方法只在redeem_work使用，redeem_work是单一优惠，不会有复合优惠条件
  def can_use_with_the_product?(product_id, user, order = nil)
    CouponCheckService.new(self, user: user, order: order).pass_with_product?(product_id)
  end

  # bdevent是单一优惠，不会有复合优惠条件
  def can_use_with_bdevent?(tmp_bdevent_id, user, order = nil)
    CouponCheckService.new(self, user: user, order: order).pass_with_bdevent?(tmp_bdevent_id)
  end

  def reach_limit?
    usage_count_limit != -1 && usage_count >= usage_count_limit
  end

  def out_of_range?
    now = Time.zone.now
    now < begin_at.in_time_zone.beginning_of_day ||
      now > expired_at.in_time_zone.end_of_day
  end

  def event?
    usage_count_limit == -1 || usage_count_limit > 1
  end

  def price(currency)
    if price_tier
      price_tier.prices[currency]
    else
      currencies.find_by(code: currency).try(:price) # 向前相容所需
    end
  end

  def threshold_price(currency)
    threshold.prices[currency]
  end

  def used?
    orders.size > 0
  end

  # children的coupon_rules使用parent的
  def root_coupon_rules
    child? ? parent.coupon_rules : coupon_rules
  end

  include CouponDiscountCalculator

  concerning :Embedable do
    # 回傳一個可以在訂單中永久保存的實體
    def embedded
      EmbeddedCoupon.new(to_embedded_hash)
    end

    private

    def to_embedded_hash
      {
        'id' => id,
        'title' => title,
        'code' => code,
        'prices' => to_prices_hash,
        'discount_type' => discount_type,
        'percentage' => percentage,
        'condition' => condition,
        'begin_at' => begin_at.to_s,
        'expired_at' => expired_at.to_s,
        'base_price_type' => base_price_type,
        'apply_count_limit' => apply_count_limit,
        'bdevent_id' => bdevent_id,
        'coupon_rules' => root_coupon_rules.map(&:to_embedded_hash),
        'is_free_shipping' => is_free_shipping,
        'is_not_include_promotion' => is_not_include_promotion
      }
    end

    def to_prices_hash
      if price_tier
        price_tier.prices
      else
        currencies.each_with_object({}) do |currency, hash|
          hash[currency.code] = currency.price
        end
      end
    end
  end

  class << self
    def valid?(code, user)
      c = Coupon.enabled.find_by(code: code.upcase)
      return c if c.present? && c.can_use?(user)
      false
    end

    def find_coupon(code)
      find_by(code: code.upcase)
    end

    def find_valid(code, user, order = nil)
      coupon = enabled.find_by!(code: code.upcase)
      fail InvalidCouponError unless coupon.can_use?(user, order)
      coupon
    rescue ActiveRecord::RecordNotFound
      raise InvalidCouponError
    end

    # 移除使用了過期 Coupon code 的 Order 且狀態是 pending
    def fallback_expired_coupon_orders
      expired_at_yesterday.find_each do |coupon|
        coupon.orders.pending.find_each(&:adjustments_coupon_revert!)
      end
    end
  end

  TO_REACT_ATTRIBUTES = %i(id quantity title code usage_count_limit price_tier_id discount_type percentage condition
                           begin_at expired_at user_usage_count_limit base_price_type apply_count_limit code_type
                           code_length is_free_shipping is_not_include_promotion can_update_expired_at).freeze

  def to_react
    react_result = TO_REACT_ATTRIBUTES.each_with_object({}) do |key, hash|
      hash[key] = send(key)
    end
    react_result[:coupon_rules] = coupon_rules.map(&:to_react)
    react_result
  end

  def create_unique_coupon_child
    children.create(child_attributes.merge(usage_count_limit: 1))
  end

  def child?
    parent.present?
  end

  def create_unique_coupon_children
    return if quantity == 1
    return if children.count == quantity
    shluld_create_quantity = quantity - children.count
    shluld_create_quantity.times do
      children.create(child_attributes.merge(usage_count_limit: 1,
                                             code_type: code_type,
                                             code_length: code_length))
    end
  end

  def free_shipping?
    is_free_shipping?
  end

  def redeem?
    condition == 'simple' &&
      root_coupon_rules.first.condition == 'include_bdevent'
  end

  def item_rules
    Array(rules_by_level['item'])
  end

  def order_rules
    Array(rules_by_level['order'])
  end

  def affecting_item?
    condition.in?(%w(rules simple)) && !ruled_with_threshold_only?
  end

  def discount_parameters
    {
      "discount_type" => discount_type,
      "percentage" => percentage,
      "price_tier_id" => price_tier_id
    }
  end

  def source_name
    "#{self.class.name}: #{title}"
  end

  private

  def ruled_with_threshold_only?
    root_coupon_rules.map(&:condition) == ['threshold']
  end

  def generate_code
    code_type = self.code_type || 'base'
    code_length = self.code_length || 6
    self.code ||= self.class.generate_code(code_type, code_length)
  end

  def set_default_range
    self.begin_at ||= Time.zone.now
    self.expired_at ||= Time.zone.now + 1.year
  end

  def upcase_code
    code.upcase!
  end

  def validates_code_should_be_uniqueness_in_the_range
    scope = self.class.available_in_range(begin_at, expired_at)
    scope = scope.where('id != ?', id) if id
    return unless scope.exists?(code: code)
    errors.add(:code, :taken)
  end

  def validates_unique_coupon_should_not_be_event
    return unless quantity > 1 && usage_count_limit != 1
    errors.add(:usage_count_limit, :child_event_coupon)
  end

  def validates_price_tier_should_be_present_if_discount_type_is_fixed
    return unless discount_type.in?(%w(fixed pay)) && price_tier.nil?
    errors.add(:price_tier, :invalid_fixed_coupon, discount_type: discount_type)
  end

  def validates_percentage_should_be_valid_if_discount_type_is_percentage
    return unless discount_type == 'percentage' && (percentage.to_f <= 0 || percentage > 1)
    errors.add(:percentage, :invalid_percentage_coupon)
  end

  def validates_usage_count_should_be_less_than_limit
    return unless usage_count_limit != -1 && usage_count > usage_count_limit
    errors.add(:usage_count_limit, :invalid_usage_count_limit)
  end

  def validates_begin_at_should_not_before_today
    errors.add(:begin_at, :invalid_begin_at) if begin_at < Time.zone.today
  end

  def validates_expired_at_should_not_before_today
    errors.add(:expired_at, :invalid_expired_at) if expired_at < Time.zone.today
  end

  def validates_by_expired_at_on_update
    errors.add(:expired_at, :invalid_expired_at_on_update) unless can_update_expired_at
  end

  # 不允許設置出现單一商品同時滿足兩個優惠條件
  # 以下情况不允许：
  #       1: 设计师 ＋ ProductModel
  #       2: 2个条件只有一个或者没有设置设计师，但是出现相同ProductModel
  #       3: 2个条件出现相同设计师并且有相同的ProductModel
  #       4: ProductCategory选择了all选项的话，另一个条件选择了［订单总额超过］之外的选项
  def validates_coupon_rules_if_include_same_model
    return if same_rules? || coupon_rules.map(&:condition).include?('threshold')
    model_ids_arr, designer_ids_arr = designers_and_models_in_coupon_rules
    has_same_designer = same_in_array(designer_ids_arr).present?
    has_same_model = same_in_array(model_ids_arr).present?
    if (designer_ids_arr.size == 1 && model_ids_arr.count == 1) ||
       ((designer_ids_arr.size < 2 || has_same_designer) && has_same_model)
      errors.add(:coupon_rules, :invalid_coupon_rules)
    end
  end

  # 为了实现第二件半折这样的coupon
  # 2个rule相同，quantity可以不同
  def same_rules?
    return true if coupon_rules.size < 2
    rules = coupon_rules.map do |coupon_rule|
      coupon_rule.attributes.delete_if { |key| key.in? %w(id quantity created_at updated_at) }
    end
    rules[0] == rules[1]
  end

  def same_in_array(array)
    array[0].to_a.map(&:to_i) & array[1].to_a.map(&:to_i)
  end

  def designers_and_models_in_coupon_rules
    model_ids_arr = [[], []]
    designer_ids_arr = [[], []]
    coupon_rules.each_with_index do |rule, index|
      case rule.condition
      when 'include_works'
        model_ids_arr[index] << rule.work_gids.map { |gid| GlobalID::Locator.locate(gid).model_id }
      when 'include_designers'
        designer_ids_arr[index] << rule.designer_ids
      when 'include_product_models'
        model_ids_arr[index] << rule.product_model_ids
      when 'include_designers_models'
        designer_ids_arr[index] << rule.designer_ids
        model_ids_arr[index] << rule.product_model_ids
      when 'include_product_categories'
        model_ids_arr[index] << ProductModel.available.map(&:id) if rule.product_category_ids.map(&:to_i).include?(-1)
        model_ids_arr[index] << ProductModel.available.where(category_id: rule.product_category_ids).map(&:id)
      end
    end
    [model_ids_arr.reject(&:blank?).each(&:flatten!), designer_ids_arr.reject(&:blank?).each(&:flatten!)]
  end

  def enqueue_create_unique_coupon_children
    return if quantity == 1
    disable
    CreateUniqueCouponChildrenWorker.perform_async(id)
  end

  def update_unique_coupon_children
    children.update_all(child_attributes)
  end

  CHILD_ATTRIBUTES = %i(title price_tier_id discount_type percentage condition
                        begin_at expired_at base_price_type apply_count_limit
                        user_usage_count_limit is_free_shipping is_not_include_promotion).freeze

  def child_attributes
    CHILD_ATTRIBUTES.each_with_object({}) do |key, hash|
      hash[key] = send(key)
    end
  end

  def rules_by_level
    rules = parent.present? ? parent.coupon_rules : coupon_rules
    @rules_by_level ||= rules.group_by(&:level)
  end

  # 到期前一日及已經到期的coupon，應該要讓user無法延長期限
  # https://ticket.commandp.com/issues/778
  def can_update_expired_at
    return true if !expired_at_changed? || expired_at_was.blank?
    Time.zone.now < (expired_at_was.end_of_day - 1.day)
  end
end
