require 'spec_helper'

describe Api::V3::CampaignsController, :api_v3, type: :controller do
  before { expect(controller).to receive(:doorkeeper_authorize!).and_call_original }

  Given(:campaign) { create(:campaign) }

  describe 'GET /campaigns' do
    context 'when user list campaigns but no available', signed_in: :guest do
      When { get :index, access_token: access_token }
      Then { response.status == 200 }
      And { expect(response).to render_template(:index) }
    end
  end

  let(:uuid) { UUIDTools::UUID.timestamp_create.to_s }

  context 'waterpackage', signed_in: :normal do
    Given { create :product_model, key: 'waterpackage_350ml' }
    Given(:payload) { [{ name: '丁一', school_name: '北大' }] }
    Given(:product_key) { 'waterpackage_350ml' }
    Given(:order_params) do
      {
        uuid: uuid,
        access_token: access_token,
        payment_method: 'paypal',
        billing_info: billing_profile_params,
        product_key: product_key,
        payload: payload
      }
    end

    context 'returns error' do
      context 'when payload error' do
        Given(:payload) { [{ s: 's', n: 'n' }] }
        When { post :waterpackage, order_params }
        Then { response.status == 400 }
        And{ Order.count == 0 }
        And{ expect(response_json['code']).to eq('OrderError') }
        And{ expect(response_json['error']).to eq('Playload keys must in (name, school_name)') }
      end

      context 'when product_key error' do
        Given(:product_key) { 'waterpackage_990ml' }
        When { post :waterpackage, order_params }
        Then { response.status == 400 }
        And{ Order.count == 0 }
        And{ expect(response_json['code']).to eq('OrderError') }
        And{ expect(response_json['error']).to match('Product key must in') }
      end
    end

    context 'returns order' do
      Given(:order) { Order.find_by(uuid: order_params[:uuid]) }
      When { post :waterpackage, order_params }
      Then { response.status == 200 }
      When(:order) { Order.find_by(uuid: order_params[:uuid]) }
      And { order.currency == 'CNY' }
      And { assert_equal 1, CreateWaterpackageWorker.jobs.size }
    end
  end
end
