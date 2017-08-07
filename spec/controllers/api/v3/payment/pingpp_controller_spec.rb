require 'spec_helper'

describe Api::V3::Payment::PingppController, :api_v3, type: :controller do
  before do
    expect(controller).to receive(:doorkeeper_authorize!).and_call_original
    expect(controller).to receive(:check_user).and_call_original
    allow(controller).to receive(:current_application).and_return(double(id: 1))
  end

  describe 'GET /begin' do
    Given(:user) { create(:user) }
    Given!(:work) { create(:work) }
    Given!(:quantity) { 5 }
    Given(:billing_info_params) { attributes_for(:billing_info) }
    Given(:shipping_info_params) { attributes_for(:shipping_info) }
    Given(:order_params) do
      {
        payment: 'pingpp_alipay',
        billing_info: billing_info_params,
        shipping_info: shipping_info_params
      }
    end
    Given!(:cart) do
      CartSession.new(controller: controller, user_id: user.id).tap do |row|
        row.add_items(work.to_gid, quantity)
        row.update_check_out(order_params)
        row.save
      end
    end
    Given!(:order) { cart.build_order.tap(&:save) }

    before do
      allow(controller).to receive(:current_country_code).and_return('CN')
      allow(controller).to receive(:current_currency_code).and_return('CNY')
    end

    context 'when a user signed in', signed_in: :guest do
      Given(:pingpp) { YAML.load(File.read("#{Rails.root}/spec/fixtures/pingpp_object_apiv3.yml")) }

      context 'when order is not valid' do
        Given(:order_params) do
          {
            payment: 'paypal',
            billing_info: billing_info_params,
            shipping_info: shipping_info_params
          }
        end
        When { get :begin, access_token: access_token, uuid: order.uuid }
        Then { response.status == 400 }
      end

      context 'when Pingpp fail: handle PingppRailsError' do
        Given(:error) { Pingpp::InvalidRequestError.new('Missing required param: success_url', 'extra', 400) }
        When { expect(Pingpp::Charge).to receive(:create).and_raise(error) }
        When { get :begin, access_token: access_token, uuid: order.uuid }
        Then { response.status == 400 }
        And { response_json['error'] == 'Missing required param: success_url' }
        And { response_json['code'] == 'Pingpp::InvalidRequestError' }
      end

      context 'timeout' do
        When { allow(Pingpp::Charge).to receive(:create).and_raise(Timeout::Error) }
        When { get :begin, access_token: access_token, uuid: order.uuid }
        Then { response.status == 400 }
        And { response_json['error'] == 'Payment Pingpp time out.' }
        And { response_json['code'] == 'ApplicationError' }
      end

      context 'order currency should be "CNY"' do
        before { order.update_attributes(currency: 'USD') }
        When { get :begin, uuid: order.uuid, access_token: access_token }
        Then { response.status == 400 }
        And { response_json['error'] == 'order currency should be CNY' }
        And { response_json['code'] == 'OrderPayError' }
      end

      context 'when order is valid' do
        before { expect(Pingpp::Charge).to receive(:create).and_return(pingpp) }
        When { get :begin, access_token: access_token, uuid: order.uuid }
        Then { response.status == 200 }
        And { response_json['amount'] == (BigDecimal(order.price.to_s) * 100).to_i }
      end

      context 'when order is valid and params with remote_ip' do
        before { expect(Pingpp::Charge).to receive(:create).and_return(pingpp) }
        When { get :begin, access_token: access_token, uuid: order.uuid, remote_ip: '192.168.1.1' }
        Then { response.status == 200 }
        And { response_json['client_ip'] == '192.168.1.1' }
      end

      context 'when payment is alipay_wap and order is valid' do
        before { expect(Pingpp::Charge).to receive(:create).and_return(pingpp) }
        Given(:order_params) do
          {
            payment: 'pingpp_alipay_wap',
            billing_info: billing_info_params,
            shipping_info: shipping_info_params
          }
        end
        When { get :begin, access_token: access_token, uuid: order.uuid, callback_url: 'http://example.com' }
        Then { response.status == 200 }
        And { response_json['amount'] == (BigDecimal(order.price.to_s) * 100).to_i }
      end

      context 'when payment is alipay_wap and params without callback_url' do
        Given(:order_params) do
          {
            payment: 'pingpp_alipay_wap',
            billing_info: billing_info_params,
            shipping_info: shipping_info_params
          }
        end
        Given(:error) { Pingpp::InvalidRequestError.new('Missing required param: success_url', 'extra', 400) }
        When { expect(Pingpp::Charge).to receive(:create).and_raise(error) }
        When { get :begin, access_token: access_token, uuid: order.uuid }
        Then { response.status == 400 }
        And { response_json['error'] == 'Missing required param: success_url' }
        And { response_json['code'] == 'Pingpp::InvalidRequestError' }
      end

      context 'when payment is upacp_wap and order is valid' do
        before { expect(Pingpp::Charge).to receive(:create).and_return(pingpp) }
        Given(:order_params) do
          {
            payment: 'pingpp_upacp_wap',
            billing_info: billing_info_params,
            shipping_info: shipping_info_params
          }
        end
        When { get :begin, access_token: access_token, uuid: order.uuid, callback_url: 'http://example.com' }
        Then { response.status == 200 }
        And { response_json['amount'] == (BigDecimal(order.price.to_s) * 100).to_i }
      end

      context 'when payment is upacp_wap and params without callback_url' do
        Given(:order_params) do
          {
            payment: 'pingpp_upacp_wap',
            billing_info: billing_info_params,
            shipping_info: shipping_info_params
          }
        end
        Given(:error) { Pingpp::InvalidRequestError.new('Missing required param: result_url', 'extra', 400) }
        When { expect(Pingpp::Charge).to receive(:create).and_raise(error) }
        When { get :begin, access_token: access_token, uuid: order.uuid }
        Then { response.status == 400 }
        And { response_json['error'] == 'Missing required param: result_url' }
        And { response_json['code'] == 'Pingpp::InvalidRequestError' }
      end

      context '200: return a paid json when order free ' do
        Given(:free_order) { create(:order, :with_free, user: user) }
        When { get :begin, access_token: access_token, uuid: free_order.uuid, auth_token: user.auth_token }
        Then { response.status == 200 }
        And { response_json['paid'] }
      end
    end
  end

  describe 'POST verify', signed_in: :guest do
    Given(:post_data) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/pingpp_webhook.json")) }

    context '#find_order_for_verify' do
      context 'need a valid order' do
        When { post :verify, uuid: 12_345, access_token: access_token }
        Then { response.status == 404 }
        And { response_json['code'] == 'RecordNotFoundError' }
      end

      context 'need a valid order with #paid? or #may_pay?' do
        Given!(:order) { create(:order, aasm_state: :canceled, user: user) }
        When { post :verify, uuid: order.uuid, access_token: access_token }
        Then { response.status == 400 }
        And { response_json['code'] == 'ApplicationError' }
      end
    end

    context '#find_pingpp_charge' do
      context 'need a correspondent Pingpp::Charge object' do
        Given(:order) { create(:pending_order, user: user) }
        When { post :verify, uuid: order.uuid, access_token: access_token }
        Then { response.status == 400 }
        And { response_json['code'] == 'Pingpp::InvalidRequestError' }
      end

      context 'need to verify Pingpp::Charge#order_no' do
        Given(:order) { create(:pending_order, user: user) }
        Given(:pingpp_charge) { post_data['data']['object'] }
        When { expect(Pingpp::Charge).to receive(:retrieve).with(order.payment_id).and_return(pingpp_charge) }
        When { post :verify, uuid: order.uuid, access_token: access_token }
        Then { response.status == 400 }
        And { response_json['code'] == 'OrderError' }
      end
    end

    context 'response status 200' do
      Given(:order) { create(:pending_order, user: user) }
      Given(:pingpp_charge) { post_data['data']['object'].merge('order_no' => order.order_no) }
      When { expect(Pingpp::Charge).to receive(:retrieve).with(order.payment_id).and_return(pingpp_charge) }
      When { post :verify, uuid: order.uuid, access_token: access_token }

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

  describe 'GET /retrieve' do
    Given(:user) { create(:user) }
    Given!(:order) { create :order, user: user }
    before do
      order.payment_id = 'ch_GqjDC0mjDyPO1mr148u5Ga11'
      order.save!
      allow(Pingpp::Charge).to receive(:retrieve).and_return(Pingpp::Charge.construct_from(id: order.payment_id,
                                                                                           order_no: order.order_no))
    end

    context 'when a user signed in', signed_in: :normal do
      context 'when order is valid' do
        When { get :retrieve, access_token: access_token, uuid: order.uuid }
        Then { response_json['id'] == order.payment_id }
        And { response_json['order_no'] == order.order_no }
      end
    end
  end
end
