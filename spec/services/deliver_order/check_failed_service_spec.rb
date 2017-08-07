require 'spec_helper'

describe DeliverOrder::CheckFailedService do
  context '.deliver_failed_service' do
    Given(:order1) { create :order, approved_at: Time.zone.now }
    Given!(:order2) { create :order, approved_at: Time.zone.now }
    Given(:remote_product) { create :product_model, remote_key: 'iphone' }
    Given(:remote_work) { create :work, product: remote_product }
    Given!(:need_deliver_order_item) { create :order_item, itemable: remote_work, order: order1, quantity: 2 }
    Then { DeliverOrder::CheckFailedService.deliver_failed_info == [{ order_id: order1.id, order_no: order1.order_no }] }
  end

  context '#receive_failed_order_ids' do
    Given(:service) { DeliverOrder::CheckFailedService.new('2015/12/25') }
    before do
      allow(service).to receive(:remote_order_ids).and_return([1, 2, 3])
      allow(service).to receive(:local_order_ids).and_return([1, 2, 3, 4])
    end
    Then { service.receive_failed_order_ids == { status: true, order_ids: [4] } }
  end
end
