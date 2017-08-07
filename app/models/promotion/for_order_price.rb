# == Schema Information
#
# Table name: promotions
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :text
#  type            :string(255)      not null
#  aasm_state      :integer
#  rule            :integer
#  rule_parameters :json
#  targets         :integer
#  begins_at       :datetime
#  ends_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  level           :integer
#

class Promotion::ForOrderPrice < Promotion
  has_many :rules, autosave: true, class_name: PromotionRule.to_s, foreign_key: 'promotion_id', dependent: :destroy
  after_initialize :set_default_values

  def applicable?(order)
    rules.any? && rules.all? { |r| r.conformed_by_order?(order) }
  end

  def build_apply_adjustment(order)
    base_price = Price.new(order.subtotal)
    adjusted_price = calculate_adjusted_price(base_price, order)
    value = (adjusted_price - base_price).to_f
    build_adjustment(order, order, self, 'apply', value, 1) if value && value != 0
  end

  def calculate_adjusted_price(base_price, order)
    case rule_parameters.discount_type
    when 'fixed'
      [base_price - price_in_currency(order.currency), Price.new(0)].max
    when 'pay'
      price_in_currency(order.currency)
    when 'percentage'
      base_price * rule.percentage.to_f
    end
  rescue => e
    raise e if Rails.env.development?
    Rollbar.error(e)
    base_price
  end

  def conditioned?
    rules.any?
  end

  private

  def set_default_values
    self.level = "order_level"
  end
end
