require 'spec_helper'

describe Payment::Neweb::MMK do
  describe '#pay' do
    it 'sets payment_id to virtualaccount', :vcr do
      order = create(:order, payment: 'neweb/mmk')
      allow(order).to receive(:price).and_return(100)
      expect(order.payment_object.pay).to be(true)
      expect(order.payment).to eq('neweb/mmk')
      expect(order.payment_id).to be_present
      expect(order.aasm_state).to eq('waiting_for_payment')
    end

    it 'sets payment_id to nil if fail', :vcr do
      order = create(:order, payment: 'neweb/mmk')
      allow(order).to receive(:price).and_return(20)
      expect(order.payment_object.pay).to be(false)
      expect(order.payment).to eq('neweb/mmk')
      expect(order.payment_id).to be_nil
      expect(order.aasm_state).to eq('pending')
    end

    it 'creates "pay" activity with payment info', :vcr do
      order = create(:order, payment: 'neweb/mmk')
      allow(order).to receive(:price).and_return(100)
      order.payment_object.pay
      activity = order.activities.last(5).first
      expect(activity.key).to eq('pay')
      expect(activity.extra_info[:payment_method]).to eq('neweb/mmk')
    end

    it 'creates "pay_ready" activity with payment info on success', :vcr do
      order = create(:order, payment: 'neweb/mmk')
      allow(order).to receive(:price).and_return(100)
      order.payment_object.pay
      _, activity = order.activities.last(2)
      expect(activity.key).to eq('pay_ready')
      expect(activity.extra_info).to include(order.payment_object.to_hash)
    end

    it 'creates "pay_fail" activity with payment info on fail', :vcr do
      order = create(:order, payment: 'neweb/mmk')
      allow(order).to receive(:price).and_return(20)
      order.payment_object.pay
      _, activity = order.activities.last(2)
      expect(activity.key).to eq('pay_fail')
      expect(order.payment_object.to_hash.stringify_keys).to include(activity.extra_info)
    end
  end

  describe '#paid?' do
    it 'returns true if neweb returns rc=-4 and rc2=72' do
      order = create(:order, payment: 'neweb/mmk')
      allow(order).to receive(:price).and_return(100)
      allow(HTTParty).to receive(:post).and_return(response = double(:response))
      allow_any_instance_of(NewebService).to receive(:parse_query).with(response).and_return('rc' => '-4', 'rc2' => '72')
      expect(order.payment_object).to be_paid
    end

    it 'returns false if neweb is not returns rc=-4 and rc2=72' do
      order = create(:order, payment: 'neweb/mmk')
      allow(order).to receive(:price).and_return(100)
      allow(HTTParty).to receive(:post).and_return(response = double(:response))
      allow_any_instance_of(NewebService).to receive(:parse_query).with(response).and_return('rc' => '0')
      expect(order.payment_object).not_to be_paid
    end
  end

  describe '#finish' do
    it 'update webhook_params and set order state to paid' do
      order = create(:order, payment: 'neweb/mmk')
      params = {'PRC' => '0'}
      expect_any_instance_of(NewebService).to receive(:valid_write_off_params?).with(params).and_return(true)
      order.payment_object.finish(params)
      order.reload
      expect(order.payment_info['webhook_params']).to eq(params)
      expect(order).to be_paid
    end

    it 'creates "paid" activity with payment info on success' do
      order = create(:order, payment: 'neweb/mmk')
      params = {'PRC' => '0'}
      expect_any_instance_of(NewebService).to receive(:valid_write_off_params?).with(params).and_return(true)
      order.payment_object.finish(params)
      activity = order.activities.last
      expect(activity.key).to eq('paid')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.merge(params).stringify_keys)
    end

    it 'creates "pay_fail" activity with payment info on fail' do
      order = create(:order, payment: 'neweb/mmk')
      params = {'PRC' => '0'}
      expect_any_instance_of(NewebService).to receive(:valid_write_off_params?).with(params).and_return(false)
      order.payment_object.finish(params)
      activity = order.activities.last
      expect(activity.key).to eq('pay_fail')
      expect(order.payment_object.to_hash.merge(params).stringify_keys).to include(activity.extra_info)
    end

    it 'raise PaymentPriceConflictError when order price is inconsistent with payment price' do
      order = create(:order, payment: 'neweb/mmk')
      order.update_column :price, 100
      params = { 'PRC' => '1', 'amount' => '9999' }
      expect{ order.payment_object.finish(params) }.to raise_error(PaymentPriceConflictError)
    end
  end

  describe '#to_hash' do
    it 'returns payment method, bank id and virtual account', :vcr do
      order = create(:order, payment: 'neweb/mmk')
      allow(order).to receive(:price).and_return(100)
      order.payment_object.pay
      payment = order.payment_object
      expect(payment.to_hash).to eq(payment_method: 'neweb/mmk',
                                    pay_code: order.payment_id)
    end
  end
end
