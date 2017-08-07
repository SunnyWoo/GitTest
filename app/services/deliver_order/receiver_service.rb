class DeliverOrder::ReceiverService
  attr_accessor :query

  def initialize(query)
    @query = query
  end

  def create
    order_receiver.new(query).create
  end

  private

  def order_receiver
    if Region.china?
      DeliverOrder::Receiver::China
    else
      DeliverOrder::Receiver::Global
    end
  end
end
