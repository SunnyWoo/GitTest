require 'spec_helper'

describe Pricing::StoreOrderPriceCalculator do
  subject(:store_calculator) { Pricing::StoreOrderPriceCalculator.new(order, target_currency) }
  subject(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
  Given(:target_currency) { order.currency }
  Given(:order) { create(:order, :priced) }
  Given(:order_promotion) { create :promotion_for_order_price }
  Given(:product_category_promotion) { create :promotion_for_product_category }
  Given(:builder) do
    Class.new do
      include ActsAsAdjustmentBuilder
    end.new
  end

  context 'with order level promotion' do
    Given {
      allow(Promotion::ForOrderPrice).to receive(:calculate_adjusted_price).and_return(Price.new(-10))
      allow(Promotion).to receive(:order_level).and_return([order_promotion])
    }

    context 'have discount when calculator is OrderPriceCalculator' do
      Given(:order_price_calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given(:pricing) { order_price_calculator.process! }
      Then { pricing[:subtotal] == 99.9 }
      And { pricing[:shipping] == 0.0 }
      And { pricing[:discount] == 10.0 }
      And { pricing[:shipping_fee_discount] == 0.0 }
      And { pricing[:price] == 89.9 }
    end

    context "don't have discount when calculator is StoreOrderPriceCalculator" do
      Given(:store_order_price_calculator) { Pricing::StoreOrderPriceCalculator.new(order, target_currency) }
      Given(:pricing) { store_order_price_calculator.process! }
      Then { pricing[:subtotal] == 99.9 }
      And { pricing[:shipping] == 0.0 }
      And { pricing[:discount] == 0.0 }
      And { pricing[:shipping_fee_discount] == 0.0 }
      And { pricing[:price] == 99.9 }
    end
  end

  context 'with product category promotion' do
    Given {
      allow_any_instance_of(HasPromotionPrice).to(
        receive(:current_promotion).and_return(product_category_promotion)
      )
      allow_any_instance_of(Promotion::ForProductCategory).to(
        receive(:calculate_adjustment_value).and_return(-10)
      )
    }

    context 'have discount when calculator is OrderPriceCalculator' do
      Given(:order_price_calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given(:pricing) { order_price_calculator.process! }
      Then { pricing[:subtotal] == 89.9 }
      And { pricing[:shipping] == 0.0 }
      And { pricing[:discount] == 0.0 }
      And { pricing[:shipping_fee_discount] == 0.0 }
      And { order.item_adjustments.sum(:value) == -10 }
      And { pricing[:price] == 89.9 }
    end

    context "don't have discount when calculator is StoreOrderPriceCalculator" do
      Given(:store_order_price_calculator) { Pricing::StoreOrderPriceCalculator.new(order, target_currency) }
      Given(:pricing) { store_order_price_calculator.process! }
      Then { pricing[:subtotal] == 99.9 }
      And { pricing[:shipping] == 0.0 }
      And { pricing[:discount] == 0.0 }
      And { pricing[:shipping_fee_discount] == 0.0 }
      And { order.item_adjustments.sum(:value) == -10 }
      And { pricing[:price] == 99.9 }
    end
  end

  context 'when gives an order' do
    it 'calculates correct amount' do
      expect(store_calculator.subtotal).to eq(99.9)
      expect(store_calculator.shipping).to eq(0)
      expect(store_calculator.discount).to eq(0)
      expect(store_calculator.price).to eq(99.9)
      expect(store_calculator.refund).to eq(0)
      expect(store_calculator.price_after_refund).to eq(99.9)
    end

    it 'calculates correct amount with special priced work' do
      itemable = create(:work, price_table: { 'USD' => 9 })
      order.order_items = [create(:order_item, itemable: itemable)]
      expect(store_calculator.subtotal).to eq(9)
      expect(store_calculator.shipping).to eq(0)
      expect(store_calculator.discount).to eq(0)
      expect(store_calculator.price).to eq(9)
      expect(store_calculator.refund).to eq(0)
      expect(store_calculator.price_after_refund).to eq(9)
    end
  end

  context 'when gives an order with fixed coupon' do
    before do
      order.coupon = create(:coupon)
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(94.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(94.9)
    end

    it 'calculates correct amount with special priced work' do
      itemable = create(:work, price_table: { 'USD' => 9 })
      order.order_items = [create(:order_item, itemable: itemable)]
      expect(calculator.subtotal).to eq(9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(9 - 5)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(4)
    end

    it 'calculates correct amount with order level adjustment' do
      builder.build_adjustment(order, order, order_promotion, :apply, -20)
      allow(calculator).to receive(:purge_promotion_order_adjustments_if_necessary)
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(20 + 5) # order level + coupon
      expect(calculator.price).to eq(74.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(74.9)
    end
  end
end
