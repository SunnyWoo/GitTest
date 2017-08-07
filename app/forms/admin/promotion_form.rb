class Admin::PromotionForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :promotion

  TYPES = %w(for_product_category for_product_model for_itemable_price for_shipping_fee).freeze

  delegate :id, :persisted?, :references,
           :name, :type, :rule, :begins_at, :ends_at, :description, :aasm_state,
           :product_category_ids, :product_ids,
           :rule_price_tier, :rule_discount_type, :rule_percentage,
           to: :promotion

  validates :name, :type, :begins_at, presence: true
  validate :beigns_at_should_not_be_in_an_hour, if: :begins_at
  validate :begins_at_should_not_be_later_than_ends_at, if: :ends_at
  validate :validate_state_editable
  validate :validate_rules
  validate :validate_rule_discount_type
  validates :rule_price_tier, presence: true, if: proc { |p| p.rule_discount_type.in? %w(fixed pay) }
  validates :rule_percentage, presence: true, if: proc { |p| p.rule_discount_type == 'percentage' }

  class << self
    def model_name
      ActiveModel::Name.new(self, nil, 'promotion')
    end
  end

  def initialize(promotion)
    @promotion = promotion
  end

  def self.type_options
    TYPES.map do |name|
      [I18n.t(name, scope: 'promotions.type_options'), "Promotion::#{name.camelize}"]
    end
  end

  def type_options
    self.class.type_options
  end

  def category_options
    categories.map do |category|
      [category.name, category.id]
    end
  end

  def discount_type_options
    Promotion::DISCOUNT_TYPES.map(&:to_sym)
  end

  def assign_attributes(attrs)
    @promotion.attributes = attrs.slice(:name, :type, :description, :rule_parameters, :product_category_ids, :product_ids)

    [:begins_at, :ends_at].each do |key|
      @promotion.send("#{key}=", Time.zone.parse(attrs[key])) if attrs[key]
    end

    if attrs[:unlimited].to_b
      @promotion.ends_at = nil
      @unlimited = true
    end

    references_attrs = attrs[:promotion_references]
    rule_attrs = attrs[:rules]

    assign_references_attributes(references_attrs) if references_attrs && with_itemable_reference?
    assign_rules_attributes(rule_attrs) if rule_attrs && with_rule?
  end

  alias_method :attributes=, :assign_attributes

  def assign_references_attributes(references_attrs)
    references_attrs.each do |_, attrs|
      ref = @promotion.references.detect { |x| x.id == attrs[:id].to_i }
      ref ||= @promotion.references.build

      if attrs[:_destroy] && ref.id
        ref.mark_for_destruction
      else
        ref.attributes = attrs.slice(:promotable_type, :promotable_id, :price_tier_id)
      end
    end
  end

  def assign_rules_attributes(rules_attrs)
    rules_attrs.each do |_, attrs|
      rule = @promotion.rules.detect { |x| x.id == attrs[:id].to_i }
      rule ||= @promotion.rules.build

      if attrs[:_destroy] && rule.id
        rule.mark_for_destruction
      else
        rule.attributes = attrs.except(:_destroy, :id)
      end
    end
  end

  def rules
    if @promotion.rules.empty?
      [@promotion.rules.build]
    else
      @promotion.rules
    end
  end

  def rule_parameters
    OpenStruct.new(@promotion.rule_parameters)
  end

  def save
    valid? && promotion.save
  end

  def unlimited
    @unlimited || (persisted? && ends_at.nil?)
  end

  def to_partial_path
    name = if persisted?
             type.demodulize.underscore
           else
             'creation'
           end

    "promotions/forms/#{name}"
  end

  def rule_condition_options
    PromotionRule::CONDITIONS.map(&:to_sym)
  end

  def categories
    ProductCategory.available.includes(:translations, products: :translations)
  end

  def search
    @search ||= StandardizedWork.is_public.ransack
  end

  private

  def validate_state_editable
    errors.add(:aasm_state) unless promotion.can_update?
  end

  def validate_rules
    return unless promotion.is_a?(Promotion::ForShippingFee)
    errors.add(:rules) if promotion.rules.empty?
  end

  def validate_rule_discount_type
    return unless persisted? && type.in?(%w(Promotion::ForProductCategory Promotion::ForProductModel))
    errors.add(:rule_discount_type) if promotion.rule_discount_type.blank?
  end

  def beigns_at_should_not_be_in_an_hour
    return unless promotion.begins_at_changed?
    errors.add(:begins_at) unless begins_at > (Time.zone.now + Promotion::MUST_START_BEFORE)
  end

  def begins_at_should_not_be_later_than_ends_at
    return unless promotion.begins_at_changed? || promotion.ends_at_changed?
    return if promotion.begins_at.nil?
    errors.add(:ends_at) unless begins_at < ends_at
  end

  def with_itemable_reference?
    @promotion.is_a?(Promotion::ForItemablePrice)
  end

  def with_rule?
    @promotion.is_a?(Promotion::ForShippingFee)
  end
end
