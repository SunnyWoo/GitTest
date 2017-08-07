class Promotion::Rule::IncludeBdevent
  include Promotion::Rule::ActsAsItemRule
  attr_reader :event_id

  def initialize(event_id, quantity)
    @event_id = event_id
    @quantity = quantity
  end

  def conformed_by_order?(order)
    return false unless order.bdevent_id.to_i == event_id.to_i
    conformed?(order.to_serial_units)
  end

  private

  def judgement?(unit)
    unit.item.itemable.in?(bdevent_works)
  end

  def bdevent_works
    @bdevent_works ||= Bdevent.find(event_id).try(:works)
  end
end
