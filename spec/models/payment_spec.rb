require 'spec_helper'

describe Payment do
  describe '.for' do
    it 'creates correct payment object' do
      Payment::PAYMENT_CLASS_MAPPING.each do |name, clazz|
        expect(Payment.for(double(:paypal, payment: name))).to be_a(clazz)
      end
    end

    it 'raises error for unsupported payment method' do
      expect {
        Payment.for(double(:paypal, payment: 'unsupported'))
      }.to raise_error
    end
  end

  describe '#to_hash' do
    it 'returns payment method' do
      payment = Payment.new(double(:paypal, payment: 'paypal'))
      expect(payment.to_hash).to eq(payment_method: 'paypal')
    end
  end

  describe '#refund' do
    before do
      create_basic_currencies
    end

    let!(:fee) { create(:fee, name: 'cash_on_delivery') }
    let(:order) do
      create(:paid_order, :with_cash_on_delivery)
    end

    it 'returns true when correctly refund' do
      payment = order.payment_object
      expect(payment.refund(order.price, note: "Testing Refund")).to eq true
      expect(order.refunds.length).to eq 1
      expect(order.refunds.first.note).to eq "Testing Refund"
      expect(order.refunds.first.amount).to eq order.price
    end

    it 'raise error when refund amoun > price' do
      payment = order.payment_object
      expect{ payment.refund(order.price + 100, note: "Testing Refund")}.to raise_error(Payment::NegativeRefundError)
    end

    it 'raise error when refund amoun = 0' do
      payment = order.payment_object
      expect{ payment.refund(0, note: "Testing Refund")}.to raise_error(Payment::InvalidRefundError)
    end
  end
end
