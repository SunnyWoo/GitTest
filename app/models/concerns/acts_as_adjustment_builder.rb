module ActsAsAdjustmentBuilder
  def find_or_create_adjustments(order, adjustable, source, event, value, quantity = 1)
    return if value.zero?
    order.adjustments.find_or_create_by adjustable: adjustable, value: value,
                                        source_type: source.class.to_s, source_id: source.id,
                                        event: Adjustment.events[event], quantity: quantity
  end

  def build_adjustment(order, adjustable, source, event, value, quantity = 1)
    relation = case adjustable
               when Order
                 order.order_adjustments
               when OrderItem
                 order.adjustments
               else
                 raise NotImplementedError, adjustable.class.to_s
               end

    adj = relation.detect do |a|
      a.source_type == source.class.to_s && a.source_id == source.id &&
        a.adjustable == adjustable && a.event.to_s == event.to_s
    end

    unless adj
      adj = relation.build(
        source: source,
        source_id: source.id,
        source_type: source.class.to_s,
        adjustable: adjustable,
        event: event.to_s
      )
      adjustable.adjustments << adj if adjustable.is_a?(OrderItem)
    end
    adj.value = value
    adj.quantity = quantity
    adj
  end
end
