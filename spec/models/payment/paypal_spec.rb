require 'spec_helper'

describe Payment::Paypal do
  before { create_basic_currencies }
  describe '#pay' do
    it 'uses paypal service' do
      order = create(:order, payment: 'paypal', currency: 'TWD')
      order.update(payment_id: '0')
      order.payment_object.pay
      expect(order.payment).to eq('paypal')
      expect(order.aasm_state).to eq('paid')
    end

    it 'creates "pay" activity with payment info' do
      order = create(:order, payment: 'paypal', currency: 'TWD')
      order.update(payment_id: '0')
      order.order_items.create(itemable: create(:work), quantity: 1) # 價格 99.9
      order.calculate_price!

      order.payment_object.pay
      activity = order.activities.find_by!(key: 'pay')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
    end

    it 'creates "paid" activity with payment info on success' do
      order = create(:order, payment: 'paypal', currency: 'TWD')
      order.update(payment_id: '0')
      order.payment_object.pay
      _, activity = order.activities.last(2)
      expect(activity.key).to eq('paid')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
    end

    it 'creates "pay_fail" activity with payment info on fail', :vcr do
      order = create(:order, :priced, payment: 'paypal')
      order.update(payment_id: 'fail')
      order.order_items.create(itemable: create(:work), quantity: 1) # 價格 99.9
      order.save
      order.payment_object.pay
      _, activity = order.activities.last(2)
      expect(activity.key).to eq('pay_fail')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
    end
  end

  describe 'paid?' do
    it 'returns true if paypal state is approved' do
      allow_any_instance_of(PaypalService).to receive(:approved?).and_return(true)
      order = create(:order, payment: 'paypal')
      order.update(payment_id: 'fail')
      expect(order.payment_object).to be_paid
    end

    it 'returns false if paypal state is not approved' do
      allow_any_instance_of(PaypalService).to receive(:approved?).and_return(false)
      order = create(:order, payment: 'paypal')
      order.update(payment_id: 'fail')
      expect(order.payment_object).not_to be_paid
    end
  end

  describe '#to_hash' do
    it 'returns payment method, bank id and virtual account', :vcr do
      order = create(:order, payment: 'paypal')
      order.payment_object.pay
      payment = order.payment_object
      expect(payment.to_hash).to eq(payment_method: 'paypal',
                                    payment_id: order.payment_id)
    end
  end
end
