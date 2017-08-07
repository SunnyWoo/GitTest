class Promotion::DiscountFormula
  delegate :percentage?, :fixed?, :pay?, to: :type
  attr_reader :currency

  def initialize(parameters)
    @rule = Hashie::Mash.new(parameters)
    @currency = Region.default_currency
  end

  def currency=(target_currency)
    @currency = target_currency
    binded_price.with_currency!(currency) unless percentage?
  end

  def calculate!(price, target_currency = nil)
    @currency = target_currency if target_currency && (target_currency != currency)
    price = price.with_currency!(currency).dup
    case type
    when 'fixed'
      ans = price - binded_price
      zero = Price.new(0, currency)
      ans > zero ? ans : zero
    when 'pay'
      binded_price > price ? price : binded_price
    when 'percentage'
      price * (1 - percentage)
    when 'none'
      0
    end
  end

  def difference!(price, target_currency = nil)
    @currency = target_currency if target_currency && (target_currency != currency)
    price = price.with_currency!(currency).dup
    case type
    when 'fixed'
      [binded_price, price].min
    when 'pay'
      ans = price - binded_price
      zero = Price.new(0, currency)
      [ans, zero].max
    when 'percentage'
      price * percentage
    when 'none'
      0
    end
  end

  def calculate(price)
    return nil unless price
    calculate!(price)
  rescue ActiveRecord::RecordNotFound
    price
  end

  def binded_price
    return nil if percentage?
    @binded_price ||= Price.new(binded_price_tier.prices, currency)
  end

  def binded_price_tier
    return nil if percentage?
    @binded_price_tier ||= PriceTier.find(@rule.price_tier_id)
  end

  def type
    @rule.discount_type.to_s.inquiry
  end

  def percentage
    return nil unless percentage?
    @rule.percentage.to_f
  end
end
