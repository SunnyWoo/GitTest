require 'spec_helper'

describe Api::V3::Payment::NewebMmkController, :api_v3, type: :controller do
  context '#begin', signed_in: :normal do
    Given(:order) { create :pending_order, :with_public_work, user: user, payment_method: 'neweb/mmk' }
    context 'returns order payment account with basic params provided', :vcr do
      When { get :begin, order_no: order.order_no, access_token: access_token }
      Then { response.status == 200 }
      And { order.reload.waiting_for_payment? }
      And { response_json['pay_code'] == order.payment_id }
      And { response_json['payment_method'] == 'neweb/mmk' }
    end

    context 'returns 400 when bad things happened' do
      before do
        expect_any_instance_of(Order).to receive_message_chain('payment_object.pay').and_return(false)
        allow_any_instance_of(Order).to receive_message_chain('payment_object.error').and_return('error')
      end
      When { get :begin, order_no: order.order_no, access_token: access_token }
      Then { response.status == 400 }
      And { response_json['paid'] == false }
    end

    context 'returns ok with free check order' do
      Given(:zero_price_order) { create :order, user: user, payment_method: 'neweb/mmk' }
      When do
        get :begin, uuid: zero_price_order.uuid, access_token: access_token
      end
      Then { response.status == 200 }
      And { zero_price_order.reload.payment_id.nil? }
      And { zero_price_order.paid? }
      And { zero_price_order.activities.find_by(key: 'pay_success').message == 'free_check' }
    end

    context 'returns 400 with non-pending order' do
      Given(:paid_order) { create :paid_order, user: user, payment_method: 'neweb/mmk' }
      When do
        get :begin, uuid: paid_order.uuid, access_token: access_token
      end
      Then { response.status == 400 }
    end

    context 'returns 404 without order_no or uuid' do
      When { get :begin, access_token: access_token }
      Then { response.status == 404 }
    end

    context 'timeout' do
      When do
        allow_any_instance_of(Order).to receive_message_chain('payment_object.pay')
          .and_raise(Timeout::Error)
      end
      When { get :begin, uuid: order.uuid, access_token: access_token }
      Then { response.status == 400 }
      And { expect(order.reload.activities.pluck(:key)).to include 'pay_fail' }
    end
  end
end
