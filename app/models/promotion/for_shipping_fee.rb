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

class Promotion::ForShippingFee < Promotion
  has_many :rules, autosave: true, class_name: PromotionRule.to_s, foreign_key: 'promotion_id', dependent: :destroy
  after_initialize :set_default_values

  AVAILABLE_COUNTRY_CODES = %w(TW CN).freeze

  def applicable?(order)
    return false unless rules.any?
    return false unless order.shipping_info.country_code.in? AVAILABLE_COUNTRY_CODES

    rules.all? { |r| r.conformed_by_order?(order) }
  end

  def effecting_orders
    Order.pending.select { |order| applicable?(order) }
  end

  %w(apply supply manual).each do |event|
    define_method(event) do |order|
      value = calculate_adjustment_value(order)
      find_or_create_adjustments(order, order, self, event, value, 1)
    end
  end

  def build_apply_adjustment(order)
    value = calculate_adjustment_value(order)
    build_adjustment(order, order, self, 'apply', value, 1)
  end

  def conditioned?
    rules.any?
  end

  private

  # 當符合免運條件卻選擇順豐速運時，運費金額應為順豐速運扣除標準運費的差價
  # 现在只有china开启了2种运送方式，防止出错，加上Region.china?限制
  def calculate_adjustment_value(order)
    shipping_way = order.shipping_info.shipping_way
    if Region.china? && shipping_way != 'standard'
      # china使用express的运费可能比standard低
      [order.shipping_fee.to_f, ShippingFeeService.new(order, nil, 'standard').price.to_f].min * -1
    else
      order.shipping_fee.to_f * -1
    end
  end

  def set_default_values
    self.level = "shipping_fee"
  end
end
