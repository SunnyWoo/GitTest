require 'spec_helper'

describe Payment::PingppAlipay do
  describe '#pay' do
    Given(:order) { create(:order, payment: 'pingpp_alipay') }
    it 'saves order' do
      allow(order).to receive(:price).and_return(100)
      order.payment_id = 'blah'
      expect(order.payment_object.pay).to be(true)
      expect(order.payment).to eq('pingpp_alipay')
      expect(order.payment_id).to be_present
      expect(order.aasm_state).to eq('pending')
    end

    it 'creates "pay_ready" activity with payment info' do
      allow(order).to receive(:price).and_return(100)
      order.payment_object.pay
      activity = order.activities.last
      expect(activity.key).to eq('pay_ready')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
    end
  end
end
