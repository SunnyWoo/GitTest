class Promotion::ShippingFeeDiscountStrategy
  attr_reader :promotion

  def initialize(promotion)
    @promotion = promotion
  end

  def apply(order)
    add_apply_adjustment(order)
  end

  def supply(order)
    add_supply_adjustment(order)
  end

  def fallback(order)
    promotion.adjustments.discount.includes(:order).where(order: order).find_each(&:fallback!)
  end

  def calculate_fallback_value(adjustable)
    if adj = adjustable.adjustments.detect { |x| x.source == promotion && x.apply? }
      adj.value * -1
    end
  end

  def calculate_adjustment_value(order)
    order.shipping_fee.to_f * -1
  end

  def build_apply_adjustment(order)
    value = calculate_adjustment_value(order)
    build_adjustments(order, value, 'apply') if value && value != 0
  end

  protected

  def add_apply_adjustment(order)
    value = calculate_adjustment_value(order)
    find_or_create_adjustments(order, value, 'apply') if value && value != 0
  end

  def add_supply_adjustment(order)
    value = calculate_adjustment_value(order)
    find_or_create_adjustments(order, value, 'supply') if value && value != 0
  end

  def add_falllback_adjustment(order)
    value = calculate_fallback_value(order)
    find_or_create_adjustments(order, value, 'fallback') if vlaue && value != 0
  end

  # each order should be effected by the same promotion only for once for now
  def find_or_create_adjustments(order, value, event)
    Adjustment.find_or_create_by adjustable: order, order: order, value: value,
                                 source_type: promotion.class.to_s, source_id: promotion.id,
                                 target: target, event: Adjustment.events[event]
  end

  def build_adjustments(order, value, event)
    adj = order.order_adjustments.detect do |a|
      a.source == promotion && a.order == order &&
        a.target == target && a.event == event
    end

    unless adj
      adj = order.order_adjustments.build(
        source: promotion, order: order,
        target: target, event: event
      )
    end
    adj.value = value
    adj
  end

  def target
    Promotion::SHIPPING_FEE_TARGET
  end
end
