require 'spec_helper'

describe Payment::CashOnDelivery do
  describe '#pay' do
    let!(:fee) { create(:fee, name: 'cash_on_delivery') }

    it 'set order status to paid' do
      order = create(:order, :with_cash_on_delivery)
      order.payment_object.pay
      expect(order.payment).to eq('cash_on_delivery')
      expect(order.aasm_state).to eq('paid')
    end

    it 'creates "paid" activity with payment info' do
      order = create(:order, :with_cash_on_delivery)
      order.payment_object.pay
      activity = order.activities.last
      expect(activity.key).to eq('paid')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
    end
  end

  describe '#paid?' do
    it 'returns true' do
      order = create(:order, :with_cash_on_delivery)
      expect(order.payment_object).to be_paid
    end
  end
end
