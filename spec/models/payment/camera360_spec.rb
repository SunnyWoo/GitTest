require 'spec_helper'

describe Payment::Camera360 do
  let(:service_response) { true }
  before do
    create_basic_currencies
    expect(Payment::Camera360::Service).to receive(:paid?).with('3345678').and_return(service_response)
  end

  describe '#pay' do
    context 'when service responds with ok' do
      it 'set order status to paid' do
        order = create(:order, :priced, payment_method: 'camera360', payment_id: '3345678')
        order.payment_object.pay
        expect(order.payment_method).to eq('camera360')
        expect(order.aasm_state).to eq('paid')
      end

      it 'creates "paid" activity with payment info' do
        order = create(:order, :priced, payment_method: 'camera360', payment_id: '3345678')
        order.payment_object.pay
        activity = order.activities.last
        expect(activity.key).to eq('paid')
        expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
      end
    end

    context 'when service responds with false' do
      let(:service_response) { false }

      it 'creates "pay_fail" activity with payment info' do
        order = create(:order, payment_method: 'camera360', payment_id: '3345678')
        order.payment_object.pay
        activity = order.activities.last
        expect(activity.key).to eq('pay_fail')
        expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
      end
    end
  end

  describe '#paid?' do
    it 'returns what service said' do
      order = create(:order, payment_method: 'camera360', payment_id: '3345678')
      payment = order.payment_object
      expect(payment).to be_paid
    end
  end
end
