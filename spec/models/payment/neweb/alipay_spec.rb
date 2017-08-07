require 'spec_helper'

describe Payment::Neweb::Alipay do
  before { create_basic_currencies }
  describe '#pay' do
    it 'saves order' do
      order = create(:order, payment: 'neweb/alipay')
      allow(order).to receive(:price).and_return(100)
      order.payment_id = 'blah'
      expect(order.payment_object.pay).to be(true)
      expect(order.payment).to eq('neweb/alipay')
      expect(order.payment_id).to be_present
      expect(order.aasm_state).to eq('pending')
    end

    it 'creates "pay_ready" activity with payment info' do
      order = create(:order, payment: 'neweb/alipay')
      allow(order).to receive(:price).and_return(100)
      order.payment_object.pay
      activity = order.activities.last
      expect(activity.key).to eq('pay_ready')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.stringify_keys)
    end
  end

  describe '#paid?' do
    it 'returns true if neweb returns rc=-4 and rc2=72' do
      order = create(:order, payment: 'neweb/alipay')
      allow(order).to receive(:price).and_return(100)
      allow(HTTParty).to receive(:post).and_return(response = double(:response))
      allow_any_instance_of(NewebService).to receive(:parse_query).with(response).and_return('rc' => '-4', 'rc2' => '72')
      expect(order.payment_object).to be_paid
    end

    it 'returns false if neweb is not returns rc=-4 and rc2=72' do
      order = create(:order, payment: 'neweb/alipay')
      allow(order).to receive(:price).and_return(100)
      allow(HTTParty).to receive(:post).and_return(response = double(:response))
      allow_any_instance_of(NewebService).to receive(:parse_query).with(response).and_return('rc' => '0')
      expect(order.payment_object).not_to be_paid
    end
  end

  describe '#to_hash' do
    it 'returns payment method and writeoff number', :vcr do
      order = create(:order, payment: 'neweb/alipay')
      allow(order).to receive(:price).and_return(100)
      order.payment_object.pay
      payment = order.payment_object
      expect(payment.to_hash).to eq(payment_method: 'neweb/alipay',
                                    writeoff_number: order.payment_id)
    end

    it 'creates "paid" activity with payment info on success' do
      order = create(:order, payment: 'neweb/alipay')
      params = {'PRC' => '0'}
      expect_any_instance_of(NewebService).to receive(:valid_write_off_params?).with(params).and_return(true)
      order.payment_object.finish(params)
      activity = order.activities.last
      expect(activity.key).to eq('paid')
      expect(activity.extra_info).to eq(order.payment_object.to_hash.merge(params).stringify_keys)
    end

    it 'creates "pay_fail" activity with payment info on fail' do
      order = create(:order, payment: 'neweb/alipay')
      params = {'PRC' => '0'}
      expect_any_instance_of(NewebService).to receive(:valid_write_off_params?).with(params).and_return(false)
      order.payment_object.finish(params)
      activity = order.activities.last
      expect(activity.key).to eq('pay_fail')
      expect(order.payment_object.to_hash.merge(params).stringify_keys).to include(activity.extra_info)
    end
  end
end
