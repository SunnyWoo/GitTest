require 'spec_helper'
require 'stripe_mock'

describe Api::V3::Payment::StripeController, :api_v3, type: :controller do
  context '#begin' do
    context 'when user signs in', signed_in: :normal do
      Given(:order) { create :pending_order, :with_public_work, user: user, payment_method: 'stripe' }
      context 'returns webpay_url with all basic params and order_no provided' do
        When { get :begin, order_no: order.order_no, access_token: access_token }
        Then { response.status == 200 }
      end

      context 'returns webpay_url with all basic params and uuid provided' do
        When { get :begin, uuid: order.uuid, access_token: access_token }
        Then { response.status == 200 }
      end

      context 'returns 404 when order is not found' do
        When { get :begin, access_token: access_token }
        Then { response.status == 404 }
      end

      context 'returns 400 with non-pending order' do
        Given(:paid_order) { create :paid_order, user: user }
        When { get :begin, access_token: access_token, order_no: paid_order.order_no }
        Then { response.status == 400 }
      end

      context 'returns ok with free check order' do
        Given(:order) { create :pending_order, user: user, payment_method: 'stripe' }
        Given { order.update(price: 0) }
        When { get :begin, access_token: access_token, order_no: order.order_no }
        Then { response.status == 200 }
        And { response_json['paid'] }
        And { response_json['message'] == 'Trigger order#pay!' }
        And { order.reload.aasm_state == 'paid' }
      end
    end
  end

  context '#veify' do
    context 'when user signs in', signed_in: :normal do
      Given(:order) { create :pending_order, :with_public_work, user: user, payment_method: 'stripe' }
      Given(:stripe_helper) { StripeMock.create_test_helper }
      before { StripeMock.start }
      after { StripeMock.stop }
      context 'returns ok with basic params provided' do
        Given(:card_token) { stripe_helper.generate_card_token }
        When { post :verify, order_no: order.order_no, card_token: card_token, access_token: access_token }
        Then { response.status == 200 }
        And { order.reload.paid? }
        And { order.payment_id.present? }
        And { order.activities.pluck(:key).include? 'paid' }
      end

      context 'returns ok with an paid order' do
        Given(:paid_order) { create :paid_order, user: user }
        When { post :verify, order_no: paid_order.order_no, access_token: access_token }
        Then { response.status == 200 }
        And { response_json['paid'] }
        And { response_json['message'] == 'The order is already paid' }
      end

      context 'returns 400 without empty card_token' do
        When { post :verify, order_no: order.order_no, access_token: access_token }
        Then { response.status == 400 }
        And { !order.reload.paid? }
      end

      context 'returns 400 with wrong card_token' do
        When { post :verify, order_no: order.order_no, card_token: 'WTF', access_token: access_token }
        Then { response.status == 400 }
        And { response_json['paid'] == false }
        And { response_json['message'] == order.activities(true).find_by(key: 'pay_fail').message }
        And { !order.reload.paid? }
      end

      context 'returns 400 with invalid card_token' do
        before { StripeMock.prepare_card_error(:card_declined) }
        Given(:card_token) { stripe_helper.generate_card_token }
        When { post :verify, order_no: order.order_no, card_token: card_token, access_token: access_token }
        Then { response.status == 400 }
        And { response_json['paid'] == false }
        And { expect(response_json['message']).to match 'The card was declined' }
        And { !order.reload.paid? }
      end

      context 'returns 400 with non-pending or paid order' do
        Given(:paid_order) { create :paid_order, user: user, aasm_state: 'shipping' }
        When { post :verify, order_no: paid_order.order_no, access_token: access_token }
        Then { response.status == 400 }
      end
    end
  end

  context '#retrieve' do
    context 'when user signs in', signed_in: :normal do
      context 'returns payment' do
        Given(:order) { create :pending_order, :with_public_work, user: user, payment_method: 'stripe' }
        Given(:stripe_helper) { StripeMock.create_test_helper }
        before do
          StripeMock.start
          post :verify, order_no: order.order_no, card_token: stripe_helper.generate_card_token,
                        access_token: access_token
        end
        When { get :retrieve, order_no: order.order_no, access_token: access_token }
        Then { response.status == 200 }
        And { response_json['id'] == order.reload.payment_id }
        And { response_json['description'] == order.order_no }
      end

      context 'returns 404 with payment_id missing or invalid' do
        Given(:order) { create :paid_order, user: user, payment_method: 'stripe' }
        When { get :retrieve, order_no: order.order_no, access_token: access_token }
        Then { response.status == 404 }
      end

      context 'returns 400 with pending order' do
        Given(:order) { create :pending_order, user: user, payment_method: 'stripe' }
        When { get :retrieve, order_no: order.order_no, access_token: access_token }
        Then { response.status == 400 }
      end
    end
  end
end
