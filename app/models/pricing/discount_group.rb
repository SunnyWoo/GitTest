class Pricing::DiscountGroup
  include Enumerable
  attr_reader :units
  delegate :each, :size, to: :units

  def initialize(discount_formula, currency = nil, units = [])
    @currency = currency || Region.default_currency
    @formula = discount_formula
    @formula.currency = @currency
    @units = units
  end

  def item
    units.any? && units[0].item
  end

  def push(units)
    @units += Array(units)
    true
  end

  def prices_by_item
    @prices_by_item ||= group_by(&:item).map do |item, units|
      [item, units.sum(&:selling_price)]
    end.to_h
  end

  def quantity_by_item
    @quantity_by_item ||= group_by(&:item).map do |item, units|
      [item, units.size]
    end.to_h
  end

  def total_price
    prices_by_item.values.sum.with_currency!(@currency)
  end

  def discount_price
    price = total_price - @formula.calculate(total_price)
    price < Price.new(0) ? Price.new(0) : price
  end

  def discount_info_by_item
    if prices_by_item.size > 1
      array = prices_by_item.to_a
      last = array.pop
      calculation = array.map do |item, partial_price|
        ratio = (partial_price.to_f / total_price.to_f)
        price = (discount_price * ratio).floor
        quantity = quantity_by_item[item]
        [item, { price: price, quantity: quantity }]
      end

      last_item = last[0]
      last_price = discount_price - calculation.sum { |a| a.last[:price] }
      last_quantity = quantity_by_item[last_item]
      calculation << [last[0], { price: last_price, quantity: last_quantity }]

      calculation.to_h
    else
      item = prices_by_item.keys.first
      { item => { price: discount_price, quantity: quantity_by_item[item] } }
    end
  end
end
