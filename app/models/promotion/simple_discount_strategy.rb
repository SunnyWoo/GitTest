class Promotion::SimpleDiscountStrategy
  # Promotion on OrderItem Level
  # parameters: value(decimal)

  attr_reader :promotion

  def initialize(promotion)
    @promotion = promotion
  end

  (Adjustment::EVENT_TYPES - %w(fallback)).each do |event|
    define_method(event) do |order|
      extract_items(order) do |effected_order_item|
        send "add_#{event}_adjustment", order, effected_order_item
      end
    end
  end

  def fallback(order)
    promotion.adjustments.discount.includes(:order).where(order: order).find_each(&:fallback!)
  end

  def calculate_fallback_value(_, adjustable)
    if adj = adjustable.adjustments.detect { |x| x.source == promotion && x.apply? }
      adj.value * -1
    end
  end

  def calculate_adjustment_value(_, item)
    currency = item.order.currency
    case promotion.rule_discount_type
    when 'fixed'
      [promotion.price_in_currency(currency), item.price_in_currency(currency)].min * -1
    when 'percentage'
      (item.price_in_currency(currency) * (promotion.rule_percentage - 1)).round 2
    when 'pay'
      promotion.price_in_currency(currency) - item.price_in_currency(currency)
    end
  end

  def calculate_adjusted_price(base_price)
    case promotion.rule_discount_type
    when 'fixed'
      [base_price - Price.new(promotion.price_tier.prices), Price.new(0)].max
    when 'percentage'
      base_price * promotion.rule_percentage
    when 'pay'
      Price.new(promotion.price_tier.prices)
    end
  end

  def build_apply_adjustment(order, adjustable)
    value = calculate_adjustment_value(order, adjustable)
    build_adjustments(order, adjustable, value, 'apply') if value
  end

  protected

  def extract_items(order)
    items = order.order_items.select { |item| promotion.applicable?(order, item) }

    if block_given?
      items.each { |item| yield(item) }
    else
      items
    end
  end

  Adjustment::EVENT_TYPES.each do |event|
    define_method "add_#{event}_adjustment" do |order, adjustable|
      value = event == 'fallback' ? calculate_fallback_value(order, adjustable) : calculate_adjustment_value(order, adjustable)
      find_or_create_adjustments(order, adjustable, value, event) if value
    end
  end

  # each order should be effected by the same promotion only for once for now
  def find_or_create_adjustments(order, adjustable, value, event)
    promotion.targets.each do |target|
      Adjustment.find_or_create_by adjustable: adjustable, order: order, value: value,
                                   source_type: promotion.class.to_s, source_id: promotion.id,
                                   target: Adjustment.targets[target], event: Adjustment.events[event]
    end
  end

  def build_adjustments(order, adjustable, value, event)
    promotion.targets.each do |target|
      adj = order.adjustments.detect do |a|
        a.source == promotion && a.adjustable == adjustable &&
          a.target == target.to_s && a.event == event
      end

      unless adj
        adj = order.adjustments.build(
          source: promotion, adjustable: adjustable,
          target: target, event: event
        )
        adjustable.adjustments << adj
      end
      adj.value = value
      adj
    end
  end
end
