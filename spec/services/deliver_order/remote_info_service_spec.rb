require 'spec_helper'

describe DeliverOrder::RemoteInfoService do
  Given(:id) { 1 }
  Given(:order) { instance_double("Order", id: id, remote_id: id) }
  Given(:access_token) { 'access_token' }
  Given(:service) { DeliverOrder::RemoteInfoService.new(order) }
  before { allow(service).to receive(:access_token).and_return('access_token') }

  context '#update' do
    context 'success' do
      before do
        stub_request(:get, "#{Settings.deliver_order.website}/api/deliver_order/remote_infos/#{id}?access_token=#{access_token}")
          .to_return(status: 200, body: '', headers: {})
        allow(service).to receive(:update_order_remote_info).and_return(true)
        allow(service).to receive(:update_order_item_remote_info).and_return(true)
      end

      Then { expect(service.update).to eq(true) }
    end

    context 'failed' do
      before do
        stub_request(:get, "#{Settings.deliver_order.website}/api/deliver_order/remote_infos/#{id}?access_token=#{access_token}")
          .to_return(status: 400, body: '', headers: {})
      end

      Then { service.update == false }
      And { service.errors.keys == [:DeliverOrderError] }
    end
  end

  context '#push' do
    context 'success' do
      before do
        stub_request(:put, "#{Settings.deliver_order.website}/api/deliver_order/remote_infos/#{id}?access_token=#{access_token}")
          .to_return(status: 200, body: '', headers: {})
        allow(service).to receive(:push_order_remote_info).and_return(true)
      end

      Then { service.push }
    end

    context 'failed' do
      before do
        stub_request(:put, "#{Settings.deliver_order.website}/api/deliver_order/remote_infos/#{id}?access_token=#{access_token}")
          .to_return(status: 400, body: '', headers: {})
        allow(service).to receive(:push_order_remote_info).and_return(true)
      end

      Then { expect { service.push }.to raise_error(DeliverOrderError) }
    end
  end

  context '#update_order_remote_info' do
    Given(:order) { create :order }
    Given(:response) do
      {
        'order_no' => '1',
        'work_state' => 'working',
        'aasm_state' => 'pending'
      }
    end

    When { service.send(:update_order_remote_info, response) }
    Then { order.remote_info == response }
  end

  context '#update_order_item_remote_info' do
    Given(:order_item) { create :order_item }
    Given(:response) do
      {
        'order_items' => [{ 'id' => order_item.id, 'aasm_state' => 'printed' }]
      }
    end

    When { service.send(:update_order_item_remote_info, response) }
    Then { order_item.reload.remote_info['aasm_state'] == 'printed' }
  end

  context '#push_order_remote_info' do
    Given(:order) { instance_double("Order", id: 1, order_no: 2, work_state: 'working', aasm_state: 'paid') }
    Given(:order_item) { instance_double('OrderItem', remote_id: 3, aasm_state: 'pending') }
    before { allow(order).to receive(:order_items).and_return([order_item]) }
    Given(:service) { DeliverOrder::RemoteInfoService.new(order) }
    Given(:result) do
      {
        order: {
          order_no: 2,
          work_state: 'working',
          aasm_state: 'paid',
          remote_id: 1
        },
        order_items: [{ id: 3, aasm_state: 'pending' }]
      }
    end

    Then { service.send(:push_order_remote_info) == result }
  end
end
