require 'spec_helper'

describe Payment::NewebMPP do
  before { create_basic_currencies }
  describe '#pay' do
    it 'saves order' do
      order = create(:order, payment: 'neweb_mpp')
      expect(order.payment_object.pay).to be(true)
    end

    it 'creates "pay" activity with payment info' do
      order = create(:order, payment: 'neweb_mpp')
      order.order_items.create(itemable: create(:work), quantity: 1) # 價格 99.9
      order.calculate_price!
      order.payment_object.pay
      activity = order.activities.last
      expect(activity.key).to eq('pay')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
    end
  end

  describe '#paid?' do
    it 'returns false' do
      order = create(:order, payment: 'neweb_mpp')
      expect(order.payment_object).not_to be_paid
    end
  end

  describe '#finish' do
    it 'update webhook_params and set order state to paid' do
      order = create(:order, payment: 'neweb_mpp')
      params = {'PRC' => '0', 'SRC' => '0'}
      expect_any_instance_of(NewebMPPService).to receive(:valid_callback_params?).with(params).and_return(true)
      order.payment_object.finish(params)
      order.reload
      expect(order.payment_info['webhook_params']).to eq(params)
      expect(order).to be_paid
    end

    it 'creates "paid" activity with payment info on success' do
      order = create(:order, payment: 'neweb_mpp')
      params = {'PRC' => '0', 'SRC' => '0'}
      expect_any_instance_of(NewebMPPService).to receive(:valid_callback_params?).with(params).and_return(true)
      order.payment_object.finish(params)
      activity = order.activities.last
      expect(activity.key).to eq('paid')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.merge(params).stringify_keys)
    end

    it 'creates "pay_fail" activity with payment info on fail' do
      order = create(:order, payment: 'neweb_mpp')
      params = {'PRC' => '1'}
      expect_any_instance_of(NewebMPPService).to receive(:valid_callback_params?).with(params).and_return(true)
      order.payment_object.finish(params)
      activity = order.activities.last
      expect(activity.key).to eq('pay_fail')
      expect(order.payment_object.to_hash.merge(params).stringify_keys).to include(activity.extra_info)
    end

    it 'creates "pay_fail" activity with payment info on invalid' do
      order = create(:order, payment: 'neweb_mpp')
      params = {'PRC' => '0'}
      expect_any_instance_of(NewebMPPService).to receive(:valid_callback_params?).with(params).and_return(false)
      order.payment_object.finish(params)
      activity = order.activities.last
      expect(activity.key).to eq('pay_fail')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.merge(params).stringify_keys)
    end

    it 'raise PaymentPriceConflictError when order price is inconsistent with payment price' do
      order = create(:order, payment: 'neweb_mpp')
      order.update_column :price, 1000
      params = { 'PRC' => '1', 'Amount' => '9999' }
      expect{ order.payment_object.finish(params) }.to raise_error(PaymentPriceConflictError)
    end
  end

  describe '#to_hash' do
    it 'returns payment method and payment_id', :vcr do
      order = create(:order, payment: 'neweb_mpp')
      allow(order).to receive(:price).and_return(100)
      order.payment_object.pay
      payment = order.payment_object
      expect(payment.to_hash).to eq(payment_method: 'neweb_mpp',
                                    payment_id: order.payment_id)
    end
  end
end
