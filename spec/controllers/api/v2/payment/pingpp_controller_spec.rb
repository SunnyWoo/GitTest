require 'spec_helper'

describe Api::V2::Payment::PingppController, type: :controller do
  before { @request.env.merge! api_header(2) }

  before do
    allow(controller).to receive(:current_country_code).and_return('CN')
    allow(controller).to receive(:current_currency_code).and_return('CNY')
  end

  Given(:user) { create(:user) }
  Given!(:work) { create(:work) }
  Given!(:quantity) { 9 }
  Given(:billing_info_params) { attributes_for(:billing_info) }
  Given(:shipping_info_params) { attributes_for(:shipping_info) }
  Given(:order_params) do
    {
      payment: 'pingpp_alipay',
      billing_info: billing_info_params,
      shipping_info: shipping_info_params
    }
  end
  Given(:cart) do
    CartSession.new(controller: controller, user_id: user.id).tap do |row|
      row.add_items(work.to_gid, quantity)
      row.update_check_out(order_params)
      row.save
    end
  end
  Given!(:order) { cart.build_order.tap(&:save) }

  describe 'GET /begin' do
    context 'payment channel not valid' do
      let(:order_params) do
        {
          payment: 'paypal',
          billing_info: billing_info_params,
          shipping_info: shipping_info_params
        }
      end
      it 'returns error' do
        get :begin, order_uuid: order.uuid, auth_token: user.auth_token
        expect(response.status).to eq(400)
        expect(response_json['code']).to eq('OrderPayError')
        expect(response_json['error']).to eq('payment method is not valid')
      end
    end

    context 'when Pingpp fail: handle PingppRailsError' do
      let(:error) { Pingpp::InvalidRequestError.new('Missing required param: success_url', 'extra', 400) }
      it 'returns error' do
        expect(Pingpp::Charge).to receive(:create).and_raise(error)
        get :begin, order_uuid: order.uuid, auth_token: user.auth_token
        expect(response.status).to eq(400)
        expect(response_json['error']).to eq('Missing required param: success_url')
        expect(response_json['code']).to eq('Pingpp::InvalidRequestError')
      end
    end

    context 'timeout' do
      it 'returns error' do
        allow(Pingpp::Charge).to receive(:create).and_raise(Timeout::Error)
        get :begin, order_uuid: order.uuid, auth_token: user.auth_token
        expect(response.status).to eq(400)
        expect(response_json['error']).to eq('Payment Pingpp time out.')
        expect(response_json['code']).to eq('ApplicationError')
      end
    end

    context 'order currency should be "CNY"' do
      before { order.update_attributes(currency: 'USD') }
      it 'returns error' do
        get :begin, order_uuid: order.uuid, auth_token: user.auth_token
        expect(response.status).to eq(400)
        expect(response_json['error']).to eq('order currency should be CNY')
        expect(response_json['code']).to eq('OrderPayError')
      end
    end

    context 'Status 200: return a Pingpp::Charge json object' do
      let(:pingpp) { YAML.load(File.read("#{Rails.root}/spec/fixtures/pingpp_object.yml")) }
      before { expect(Pingpp::Charge).to receive(:create).and_return(pingpp) }
      it 'returns ok' do
        get :begin, order_uuid: order.uuid, auth_token: user.auth_token
        expect(response.status).to eq(200)
        expect(response_json['amount']).to eq((BigDecimal(order.price.to_s) * 100).to_i)
        expect(order.reload.payment_id).to eq(response_json['id'])
      end
    end

    context '200: return a paid json when order free ' do
      let(:free_order) { create(:order, :with_free, user: user) }
      it 'returns ok' do
        get :begin, order_uuid: free_order.uuid, auth_token: user.auth_token
        expect(response.status).to eq(200)
        expect(response_json['paid']).to be_truthy
      end
    end
  end

  Given(:post_data) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/pingpp_webhook.json")) }

  describe 'GET verify' do
    context '#find_order_for_verify' do
      context 'need a valid order' do
        When { get :verify, uuid: 12_345, auth_token: user.auth_token }
        Then { response.status == 404 }
        And { response_json['code'] == 'RecordNotFoundError' }
      end

      context 'need a valid order with #paid? or #may_pay?' do
        Given!(:order) { create(:order, aasm_state: :canceled, user: user) }
        When { get :verify, uuid: order.uuid, auth_token: user.auth_token }
        Then { response.status == 400 }
        And { response_json['code'] == 'ApplicationError' }
      end
    end

    context '#find_pingpp_charge' do
      context 'need a correspondent Pingpp::Charge object' do
        Given(:order) { create(:pending_order, user: user) }
        When { get :verify, uuid: order.uuid, auth_token: user.auth_token }
        Then { response.status == 400 }
        And { response_json['code'] == 'Pingpp::InvalidRequestError' }
      end

      context 'need to verify Pingpp::Charge#order_no' do
        Given(:order) { create(:pending_order, user: user) }
        Given(:pingpp_charge) { post_data['data']['object'] }
        When { expect(Pingpp::Charge).to receive(:retrieve).with(order.payment_id).and_return(pingpp_charge) }
        When { get :verify, uuid: order.uuid, auth_token: user.auth_token }
        Then { response.status == 400 }
        And { response_json['code'] == 'OrderError' }
      end
    end

    context 'response status 200' do
      Given(:order) { create(:pending_order, user: user) }
      Given(:pingpp_charge) { post_data['data']['object'].merge('order_no' => order.order_no) }
      When { expect(Pingpp::Charge).to receive(:retrieve).with(order.payment_id).and_return(pingpp_charge) }
      When { get :verify, uuid: order.uuid, auth_token: user.auth_token }

      context 'when Pingpp::Charge data is not paid' do
        Given(:pingpp_charge) { post_data['data']['object'].merge('order_no' => order.order_no, 'paid' => false) }
        Then { response.status == 200 }
        And { response_json['paid'] == false }
        And { order.reload.paid? == false }
      end

      context 'when Pingpp::Charge data is paid and the order is not paid' do
        Then { response.status == 200 }
        And { response_json['paid'] == true }
        And { order.reload.paid? == true }
      end

      context 'when Pingpp::Charge data is paid and the order is paid' do
        Given(:order) { create(:paid_order, user: user) }
        Then { response.status == 200 }
        And { response_json['paid'] == true }
        And { order.reload.paid? == true }
      end
    end
  end
end
