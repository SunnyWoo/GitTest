class DeliverOrder::CancelRemoteOrder < DeliverOrder::BaseService
  attr_accessor :order

  def initialize(order)
    @order = order
    super()
  end

  def execute
    put("orders/#{order.id}/cancel")
    true
  rescue => e
    errors.add(e.class.name, message: e.to_s)
    false
  end
end
