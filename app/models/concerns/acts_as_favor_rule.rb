module ActsAsFavorRule
  extend ActiveSupport::Concern

  CONDITIONS = %w(
    threshold
    include_designers
    include_product_models
    include_works
    include_designers_models
    include_product_categories
    include_bdevent
    include_free_shipping_coupon
  ).freeze

  included do
    belongs_to :threshold, class_name: 'PriceTier'
    belongs_to :bdevent
    validates :condition, inclusion: CONDITIONS
    validates_presence_of :threshold_id, if: :threshold?, message: :invalid_threshold_coupon
    validates_presence_of :designer_ids, if: :check_designers?, message: :invalid_designer_ids
    validates_presence_of :product_model_ids, if: :check_product_models?, message: :invalid_product_model_ids
    validates_presence_of :work_gids, if: :include_works?, message: :invalid_work_gids
    validates_presence_of :product_category_ids, if: :include_product_categories?, message: :invalid_product_category_ids
    validates :bdevent_id, presence: true, if: :include_bdevent?
  end

  delegate :conformed?, :conformed_by_order?, :extract, to: :strategy
  delegate *(CONDITIONS.map { |str| "#{str}?" }), to: :_condition_inquiry

  def strategy
    @strategy ||= load_strategy
  end

  def item_level?; level == 'item'; end

  def order_level?; level == 'order'; end

  def level
    condition.in?(%w(threshold)) ? 'order' : 'item'
  end

  private

  def _condition_inquiry
    condition.to_s.inquiry
  end

  def load_strategy
    case condition
    when 'threshold'
      threshold_price = Price.new(threshold.prices)
      Promotion::Rule::Threshold.new(threshold_price)
    when 'include_product_models'
      members = ProductModel.where(id: product_model_ids)
      Promotion::Rule::IncludeProductModels.new(members, quantity)
    when 'include_product_categories'
      members = ProductCategory.where(id: product_category_ids)
      options = { all: (product_category_ids == [-1]) }
      Promotion::Rule::IncludeProductCategories.new(members, quantity, options)
    when 'include_designers'
      members = Designer.where(id: designer_ids)
      Promotion::Rule::IncludeDesigners.new(members, quantity)
    when 'include_works'
      members = work_gids.map { |gid| GlobalID::Locator.locate(gid) }
      Promotion::Rule::IncludeWorks.new(members, quantity)
    when 'include_designers_models'
      designers = Designer.where(id: designer_ids)
      models = ProductModel.where(id: product_model_ids)
      Promotion::Rule::IncludeDesignerModels.new(designers, models, quantity)
    when 'include_bdevent'
      Promotion::Rule::IncludeBdevent.new(bdevent_id, quantity)
    when 'include_free_shipping_coupon'
      Promotion::Rule::IncludeFreeShippingCoupon.new
    else
      raise NotImplementedError, condition
    end
  end

  def check_designers?
    include_designers? || include_designers_models?
  end

  def check_product_models?
    include_product_models? || include_designers_models?
  end
end
