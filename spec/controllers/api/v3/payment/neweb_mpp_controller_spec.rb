require 'spec_helper'

describe Api::V3::Payment::NewebMppController, :api_v3, type: :controller do
  context '#begin', signed_in: :normal do
    Given(:order) { create :pending_order, :with_public_work, user: user, payment_method: 'neweb_mpp' }
    Given(:valid_url) { token.application.redirect_uri }
    context 'returns ok with basic params provided', :vcr do
      When { get :begin, order_no: order.order_no, return_url: valid_url, access_token: access_token }
      Then { response.status == 200 }
    end

    context 'returns ok with basic params provided', :vcr do
      When { get :begin, uuid: order.uuid, return_url: valid_url, access_token: access_token }
      Then { response.status == 200 }
    end

    context 'returns ok with free check order' do
      Given(:zero_price_order) { create :order, user: user, payment_method: 'neweb_mpp' }
      When do
        get :begin, uuid: zero_price_order.uuid, return_url: valid_url, access_token: access_token
      end
      Then { response.status == 200 }
      And { zero_price_order.reload.payment_id.nil? }
      And { zero_price_order.activities.find_by(key: 'pay_success').message == 'free_check' }
    end

    context 'returns 400 with non-pending order' do
      Given(:paid_order) { create :paid_order, user: user, payment_method: 'neweb_mpp' }
      When do
        get :begin, uuid: paid_order.uuid, access_token: access_token, return_url: valid_url
      end
      Then { response.status == 400 }
    end

    context 'returns 400 without return_url' do
      When { get :begin, uuid: order.uuid, access_token: access_token }
      Then { response.status == 400 }
    end

    context 'returns 400 with invalid return_url' do
      When { get :begin, uuid: order.uuid, return_url: 'WTF.com/lala', access_token: access_token }
      Then { response.status == 400 }
    end

    context 'returns 404 without order_no or uuid' do
      When { get :begin, return_url: valid_url, access_token: access_token }
      Then { response.status == 404 }
    end

    context 'timeout' do
      When do
        allow_any_instance_of(Order).to receive_message_chain('payment_object.webpay_url')
          .and_raise(Timeout::Error)
      end
      When { get :begin, uuid: order.uuid, return_url: valid_url, access_token: access_token }
      Then { response.status == 400 }
      And { expect(order.reload.activities.pluck(:key)).to include 'pay_fail' }
    end
  end

  context '#verify', signed_in: :normal do
    Given(:order) { create :pending_order, :with_public_work, user: user, payment_method: 'neweb_mpp' }
    context 'returns ok if webhook makes order paid' do
      When { order.pay! }
      When { post :verify, order_no: order.order_no, access_token: access_token }
      Then { response.status == 200 }
    end

    context 'returns 400 if webhook has not made order paid yet' do
      before do
        get :begin, order_no: order.order_no, return_url: token.application.redirect_uri,
                    access_token: access_token
      end
      When { post :verify, order_no: order.order_no, access_token: access_token }
      Then { response.status == 400 }
      And { response_json['message'] == 'Please wating for neweb/mpp webhook' }
    end

    context 'returns 400 if the order did not make any begin request' do
      When { post :verify, order_no: order.order_no, access_token: access_token }
      Then { response.status == 400 }
      And { response_json['message'] == 'The order did not make any begin request' }
    end

    context 'returns 400 if is non-pending or paid order' do
      Given(:shipping_order) { create :order, user: user, aasm_state: 'shipping' }
      When { post :verify, order_no: shipping_order.order_no, access_token: access_token }
      Then { response.status == 400 }
    end
  end
end
