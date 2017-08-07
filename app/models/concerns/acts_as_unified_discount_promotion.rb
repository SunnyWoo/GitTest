module ActsAsUnifiedDiscountPromotion
  extend ActiveSupport::Concern
  include HasDiscountFormula

  included do
    has_discount_formula :rule_parameters
  end

  def fetch_promotion_price(promotable)
    base_price = Price.new(promotable.special_prices)
    calculate_adjusted_price(base_price)
  end

  def calculate_adjusted_price(base_price)
    discount_formula.calculate!(base_price)
  rescue => e
    raise e if Rails.env.development?
    Rollbar.error(e)
    base_price
  end

  def conditioned?
    references.any?
  end

  private

  def price_in_rule
    @price_in_rule ||= Price.new(PriceTier.find(rule_parameters.price_tier_id).prices)
  end
end
