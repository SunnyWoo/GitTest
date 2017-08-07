require 'spec_helper'

describe Webhook::PingppController, type: :controller do
  Given(:post_pay_data) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/pingpp_webhook.json")) }
  Given(:post_refund_data) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/pingpp_refund_webhook.json")) }

  describe 'POST callback' do
    context '#check_valid_event' do
      When { post_pay_data.merge!('type' => 'xxx') }
      When { post :callback, post_pay_data.to_json }
      Then { response.status == 400 }
      And { response_json['code'] == 'ApplicationError' }
    end

    context '#verify_signature' do
      When { post :callback, post_pay_data.to_json }
      Then { response.status == 401 }
    end

    context 'signature verifed, pay' do
      before { expect(controller).to receive(:verify_signature).and_return(true) }
      Given!(:order) { create(:pending_order, price: 100) }

      context 'when order is not found' do
        When { post :callback, post_pay_data.to_json }
        Then { response.status == 404 }
      end

      context 'when order is found and pay success' do
        before { post_pay_data['data']['object']['order_no'] = order.order_no }
        When { post :callback, post_pay_data.to_json }
        Then { response.status == 200 }
        And { order.reload.paid? == true }
        And { order.payment_id == post_pay_data['data']['object']['id'] }
      end
    end

    context 'signature verifed, refund' do
      Given(:order) { create(:order, :priced, :with_pingpp_alipay, currency: 'TWD') }
      before { expect(controller).to receive(:verify_signature).and_return(true) }
      before { order.order_items << create(:order_item) }
      before { stub_env('REGION', 'china') }

      context 'when order is not found' do
        Given { allow(Pingpp::Charge).to receive(:retrieve).and_return(Pingpp::Charge.construct_from(order_no: '123')) }
        When { post :callback, post_refund_data.to_json }
        Then { response.status == 404 }
      end

      context 'when order is found and refund success' do
        Given { allow(Pingpp::Charge).to receive(:retrieve).and_return(Pingpp::Charge.construct_from(order_no: order.order_no)) }

        When { post :callback, post_refund_data.to_json }
        Then { response.status == 200 }
        And { order.reload.part_refunded? == true }
      end
    end
  end
end
