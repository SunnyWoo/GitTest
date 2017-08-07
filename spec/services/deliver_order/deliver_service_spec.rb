require 'spec_helper'

describe DeliverOrder::DeliverService do
  context '#execute' do
    Given(:order) { create :order }
    Given(:remote_product) { create :product_model, remote_key: 'iphone' }
    Given(:remote_work) { create :work, product: remote_product }
    Given!(:need_deliver_order_item) { create :order_item, itemable: remote_work, order: order, quantity: 2 }
    Given!(:order_item) { create :order_item, order: order, quantity: 3 }
    Given(:service) { DeliverOrder::DeliverService.new(order.reload) }
    Given(:access_token) { 'access_token' }
    before { allow(service).to receive(:access_token).and_return('access_token') }

    context 'call_remote_api return status 200' do
      before do
        stub_request(:post, "#{Settings.deliver_order.website}/api/deliver_order/orders?access_token=#{access_token}")
          .to_return(status: 200, body: '', headers: {})
      end
      When { service.execute }
      Then { order.delivered_at? }
      And { order.flags? :internal_transfer }
      And { need_deliver_order_item.reload.delivered == true }
      And { order_item.reload.delivered == false }
      And { UpdateRemoteInfoWorker.jobs.size == 1 }
    end

    context 'call_remote_api return status not 200' do
      before do
        stub_request(:post, "#{Settings.deliver_order.website}/api/deliver_order/orders?access_token=#{access_token}")
          .to_return(status: 404, body: '', headers: {})
      end
      Then { expect { service.execute }.to raise_error(DeliverOrderError) }
    end
  end
end
