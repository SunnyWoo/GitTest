require 'spec_helper'
require 'stripe_mock'

describe Stripe::ChargeService do
  context '#charge' do
    let(:order) do
      order = create(:order, :with_stripe)
      order.order_items = [create(:iphone6_order_item)]
      order.save
      order.tap(&:reload)
      order
    end
    let(:token) { StripeMock.create_test_helper.generate_card_token }
    before { StripeMock.start }
    after { StripeMock.stop }

    it 'return true with correct data' do
      expect(Stripe::ChargeService.new(order, token).execute).to eq true
      expect(order.reload.paid?).to eq(true)
      expect(order.activities.where(key: 'paid').count).not_to be(0)
    end

    it 'return false with wrong stripe token' do
      expect(Stripe::ChargeService.new(order, 'token').execute).to eq false
      expect(order.activities.where(key: 'pay_fail').all).not_to be_empty
    end
  end
end
