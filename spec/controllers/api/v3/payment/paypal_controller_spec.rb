require 'spec_helper'

describe Api::V3::Payment::PaypalController, :api_v3, type: :controller do
  context '#begin' do
    context 'when user sign in', signed_in: :normal do
      Given(:order) { create :pending_order, user: user, payment_method: 'paypal' }
      Given(:valid_url) { token.application.redirect_uri }
      context 'when order is fine', :vcr do
        context 'returns ok with uuid provided' do
          When do
            get :begin, order_no: order.order_no, return_url: valid_url,
                        cancel_url: valid_url, access_token: access_token
          end
          Then { response.status == 200 }
          And { expect(order.reload.payment_id).not_to be_nil }
        end

        context 'returns ok with uuid provided' do
          When do
            get :begin, uuid: order.uuid, return_url: valid_url,
                        cancel_url: valid_url, access_token: access_token
          end
          Then { response.status == 200 }
          And { expect(order.reload.payment_id).not_to be_nil }
        end

        context 'returns ok with free_check order' do
          Given(:zero_price_order) { create :order, user: user, payment_method: 'paypal' }
          When do
            get :begin, uuid: zero_price_order.uuid, return_url: valid_url,
                        cancel_url: valid_url, access_token: access_token
          end
          Then { response.status == 200 }
          And { zero_price_order.reload.payment_id.nil? }
          And { zero_price_order.activities.find_by(key: 'pay_success').message == 'free_check' }
        end
      end

      context 'returns 404 when order is not found' do
        When { get :begin, return_url: 'commandp.com.cn/path', access_token: access_token }
        Then { response.status == 404 }
      end

      context 'returns 400 with invalid return_url ' do
        When { get :begin, order_no: order.order_no, return_url: 'hacker.com.cn/path', access_token: access_token }
        Then { response.status == 400 }
      end

      context 'returns 400 with invalid cancel_url ' do
        When { get :begin, order_no: order.order_no, return_url: 'hacker.com.cn/path', access_token: access_token }
        Then { response.status == 400 }
      end

      context 'returns 400 with none-pending order' do
        Given(:paid_order) { create :paid_order, user: user, payment_method: 'paypal' }
        When do
          get :begin, uuid: paid_order.uuid, access_token: access_token, return_url: valid_url, cancel_url: valid_url
        end
        Then { response.status == 400 }
      end

      context 'returns 400 without return_url', :vcr do
        When { get :begin, uuid: order.uuid, access_token: access_token, cancel_url: valid_url }
        Then { response.status == 400 }
      end

      context 'returns 400 without cancel_url', :vcr do
        When { get :begin, uuid: order.uuid, access_token: access_token, return_url: valid_url }
        Then { response.status == 400 }
      end

      context 'timeout' do
        When do
          allow_any_instance_of(Order).to receive_message_chain('payment_object.webpay_url')
            .and_raise(Timeout::Error)
        end
        When do
          get :begin, uuid: order.uuid, return_url: valid_url,
                      cancel_url: valid_url, access_token: access_token
        end
        Then { response.status == 400 }
        And { expect(order.reload.activities.pluck(:key)).to include 'pay_fail' }
      end
    end
  end

  context '#verify' do
    context 'when user signs in', signed_in: :normal do
      context 'returns ok when everything is fine' do
        Given(:order) do
          create :pending_order, :with_public_work, user: user, payment_method: 'paypal', payment_id: '12345'
        end
        Given(:service) { instance_spy('PayPal::SDK::REST::Payment', state: 'approved') }
        When { expect(PayPal::SDK::REST::Payment).to receive(:find).with('12345').and_return(service) }
        When { expect(service).to receive(:execute).with(payer_id: '123456').and_return(true) }
        When { post :verify, payer_id: '123456', order_no: order.order_no, access_token: access_token }
        Then { response.status == 200 }
        And { order.reload.paid? }
        And { order.activities.pluck(:key).include? 'paid' }
        And { response_json['paid'] }
      end

      context 'returns 400 with paypal payment state is not approved' do
        Given(:order) do
          create :pending_order, :with_public_work, user: user, payment_method: 'paypal', payment_id: '12345'
        end
        Given(:service) { instance_spy('PayPal::SDK::REST::Payment', state: 'WTF') }
        When { expect(PayPal::SDK::REST::Payment).to receive(:find).with('12345').and_return(service) }
        When { expect(service).to receive(:execute).with(payer_id: '123456').and_return(true) }
        When { post :verify, payer_id: '123456', order_no: order.order_no, access_token: access_token }
        Then { response.status == 400 }
        And { !order.reload.paid? }
        And { order.activities.pluck(:key).include? 'pay_fail' }
        And { !response_json['paid'] }
      end

      context 'returns 400 with payment is not found', :vcr do
        Given(:order) do
          create :pending_order, :with_public_work, user: user, payment_method: 'paypal', payment_id: '12345'
        end
        When { post :verify, order_no: order.order_no, access_token: access_token }
        Then { response.status == 404 }
      end

      context 'returns 400 with invalid payer_id', :vcr do
        Given(:order) do
          create :pending_order, :with_public_work, user: user, payment_method: 'paypal', payment_id: '12345'
        end
        Given(:valid_url) { token.application.redirect_uri }
        When do
          get :begin, order_no: order.order_no, return_url: valid_url,
                      cancel_url: valid_url, access_token: access_token
        end
        When { post :verify, order_no: order.reload.order_no, access_token: access_token, payer_id: '123133' }
        Then { response.status == 400 }
      end

      context 'returns ok when order is paid' do
        Given(:paid_order) { create :paid_order, payment_method: 'paypal', user: user }
        When { post :verify, order_no: paid_order.order_no, access_token: access_token }
        Then { response.status == 200 }
        And { response_json['paid'] }
        And { response_json['message'] == 'The order is already paid' }
      end

      context 'returns 400 with neither of paid or pending order' do
        Given(:order) { create :order, user: user, aasm_state: 'shipping' }
        When { post :verify, order_no: order.order_no, access_token: access_token }
        Then { response.status == 400 }
      end

      context 'returns 404 without uuid or order_no' do
        When { post :verify, access_token: access_token }
        Then { response.status == 404 }
      end
    end
  end

  context '#retrieve', signed_in: :normal do
    Given(:order) { create :pending_order, user: user, payment_method: 'paypal' }
    context 'returns payment', :vcr do
      Given(:valid_url) { token.application.redirect_uri }
      When do
        get :begin, order_no: order.order_no, return_url: valid_url,
                    cancel_url: valid_url, access_token: access_token
      end
      When { get :retrieve, order_no: order.order_no, access_token: access_token }
      Then { response.status == 200 }
      And { response_json['id'] == order.reload.payment_id }
    end

    context 'returns 404 with invalid payment_id', :vcr do
      before { order.update payment_id: '123456' }
      When { get :retrieve, order_no: order.order_no, access_token: access_token }
      Then { response.status == 404 }
    end
  end
end
