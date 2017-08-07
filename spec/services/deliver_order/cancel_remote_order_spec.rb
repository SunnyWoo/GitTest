require 'spec_helper'

describe DeliverOrder::CancelRemoteOrder do
  context '#execute' do
    Given(:id) { 1 }
    Given(:order) { instance_double("Order", id: id) }
    Given(:access_token) { 'access_token' }
    Given(:service) { DeliverOrder::CancelRemoteOrder.new(order) }

    before { allow(service).to receive(:access_token).and_return('access_token') }
    context 'success' do
      before do
        stub_request(:put, "#{Settings.deliver_order.website}/api/deliver_order/orders/#{id}/cancel?access_token=#{access_token}")
          .to_return(status: 200, body: '', headers: {})
      end

      Then { service.execute == true }
    end

    context 'failed' do
      before do
        stub_request(:put, "#{Settings.deliver_order.website}/api/deliver_order/orders/#{id}/cancel?access_token=#{access_token}")
          .to_return(status: 400, body: '', headers: {})
      end

      Then { service.execute == false }
      And { service.errors.keys == [:DeliverOrderError] }
    end
  end
end
