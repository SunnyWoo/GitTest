require 'spec_helper'

RSpec.describe Api::V3::DeliverOrder::OrdersController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }
  Given(:query) { { order_id: 48 } }

  describe 'POST /orders' do
    context 'when a user signed in', signed_in: :guest do
      When { post :create, access_token: access_token, query: query }
      Then { response.status == 200 }
      And { CreateDeliveryOrderWorker.jobs.size == 1 }
    end

    # context 'when worker is exist', signed_in: :guest do
    #   before do
    #     allow(controller).to receive(:the_worker_exist?).and_return(true)
    #   end
    #   When { post :create, access_token: access_token, query: query }
    #   Then { response.status == 200 }
    #   And { CreateDeliveryOrderWorker.jobs.size == 0 }
    # end
  end

  describe 'put /cancel' do
    Given!(:order) { create :order, remote_id: 10 }
    context 'when a user signed in', signed_in: :guest do
      When { put :cancel, access_token: access_token, order_id: 10 }
      Then { response.status == 200 }
      And { order.reload.aasm_state == 'canceled' }
    end
  end
end
