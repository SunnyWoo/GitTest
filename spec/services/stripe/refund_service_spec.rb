require 'spec_helper'
require 'stripe_mock'

describe Stripe::RefundService do
  context '#refund' do
    let(:order) do
      order = create(:order, :with_stripe)
      order.order_items = [create(:iphone6_order_item)]
      order
    end
    let(:token) do
      StripeMock.create_test_helper.generate_card_token
    end

    let(:refund_service) do
      Stripe::RefundService.new(order)
    end

    before do
      StripeMock.start
      Stripe::ChargeService.new(order, stripe_token: token).execute
      create(:twd_currency_type)
      create(:usd_currency_type)
    end

    after do
      StripeMock.stop
    end

    it 'works for part_refunded correctly' do
      amount = 10
      refund_service.execute(amount)
      expect(order.part_refunded?).to eq true
    end

    it 'works for refunded correctly' do
      amount = 29
      refund_service.execute(amount, 'Test King!')
      expect(order.refunded?).to eq true
      expect(order.refunds.last.note).to eq 'Test King!'
      expect(order.reload.refunds.last.amount).to eq 29
    end

    it 'fails if refund price is greater than what it paid at first' do
      amount = 100
      refund_service.execute(amount)
      expect(order.paid?).to eq true
    end
  end
end
