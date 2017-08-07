require 'spec_helper'

describe DeliverOrder::OrderItemService do
  Given(:order_item_id) { 1 }
  Given(:access_token) { 'access_token' }
  Given(:service) { DeliverOrder::OrderItemService.new(order_item_id) }
  before { allow(service).to receive(:access_token).and_return('access_token') }

  context '#execute' do
    before do
      stub_request(:get, "#{Settings.deliver_order.website}/api/deliver_order/order_items/#{order_item_id}?access_token=#{access_token}")
        .to_return(status: 200, body: 'body', headers: {})
    end

    Then { service.execute.body == 'body' }
  end
end
