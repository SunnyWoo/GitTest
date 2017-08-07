require 'spec_helper'

RSpec.describe Api::V3::DeliverOrder::RemoteInfosController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }
  Given!(:order) { create :order, remote_id: 1 }

  describe 'GET /api/deliver_order/remote_infos' do
    Given!(:order2) { create :order, remote_id: 3 }
    context 'return 200 when remote_id is exist', signed_in: :guest do
      When { get :index, access_token: access_token, remote_ids: [1, 2, 3] }
      Then { response.status == 200 }
      And { response_json['remote_ids'].sort == [1, 3] }
    end

    context 'return 404 when remote_id is not exist', signed_in: :guest do
      When { get :show, access_token: access_token, remote_id: 2 }
      Then { response.status == 404 }
    end
  end

  describe 'GET /api/deliver_order/remote_info' do
    context 'return 200 when remote_id is exist', signed_in: :guest do
      When { get :show, access_token: access_token, remote_id: 1 }
      Then { response.status == 200 }
      And { expect(response_json['order_id']).to eq order.id }
      And { expect(response_json['remote_id']).to eq order.remote_id }
      And { expect(response_json['work_state']).to eq order.work_state }
      And { expect(response_json['aasm_state']).to eq order.aasm_state }
    end

    context 'return 404 when remote_id is not exist', signed_in: :guest do
      When { get :show, access_token: access_token, remote_id: 2 }
      Then { response.status == 404 }
    end
  end

  describe 'PUT /api/deliver_order/remote_info' do
    context 'return 200 when remote_id is exist', signed_in: :guest do
      Given (:order_item) { create(:order_item) }
      Given { order.order_items << order_item }
      Given (:query) do
        {
          order: { order_no: '123456789CN',
                   work_state: 'ongoing',
                   aasm_state: 'paid',
                   remote_id: '1' },
          order_items: [{ id: order_item.id, aasm_state: 'sublimated' }]
        }
      end
      When { put :update, { access_token: access_token, remote_id: order.id }.merge(remote_info: query) }
      Then { response_json['status'] == true }
      And { order.reload.remote_info == query[:order].as_json }
      And { order_item.reload.remote_info['aasm_state'] == 'sublimated' }
    end

    context 'return 404 when remote_id is not exist', signed_in: :guest do
      When { put :update, access_token: access_token, remote_id: 333 }
      Then { response.status == 200 }
      And { response_json['status'] == false }
    end
  end
end
