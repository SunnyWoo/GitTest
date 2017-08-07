require 'spec_helper'

describe Payment::NuandaoB2b do
  let(:service_response) { "{\"status\":\"ok\"}" }
  before do
    stub_request(:post, Settings.nuandao_b2b.order_confirm_url).
      to_return(status: 200, body: service_response)
  end

  describe '#pay' do
    context 'when service responds with ok' do
      it 'set order status to paid' do
        order = create(:order, payment_method: 'nuandao_b2b', payment_id: '123456789')
        order.payment_object.pay
        expect(order.payment_method).to eq('nuandao_b2b')
        expect(order.aasm_state).to eq('paid')
      end

      it 'creates "paid" activity with payment info' do
        order = create(:order, payment_method: 'nuandao_b2b', payment_id: '123456789')
        order.payment_object.pay
        activity = order.activities.last
        expect(activity.key).to eq('paid')
        expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
      end
    end

    context 'when service responds with false' do
      let(:service_response) { "{\"status\":\"fail\"}" }

      it 'creates "pay_fail" activity with payment info' do
        order = create(:order, payment_method: 'nuandao_b2b', payment_id: '3345678')
        order.payment_object.pay
        activity = order.activities.last
        expect(activity.key).to eq('pay_fail')
        expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
      end
    end
  end

  describe '#paid?' do
    it 'returns what service said' do
      order = create(:order, payment_method: 'nuandao_b2b', payment_id: '3345678')
      payment = order.payment_object
      expect(payment).to be_paid
    end
  end
end
