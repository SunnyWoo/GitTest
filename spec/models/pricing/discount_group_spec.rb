require 'spec_helper'

describe Pricing::DiscountGroup do
  Given(:group) { Pricing::DiscountGroup.new(discount_formula) }
  Given(:discount_formula) { build :discount_formula, :fixed, price_table: { 'TWD' => 100.0 } }
  Given { create_basic_currencies }

  Then { expect(group.size).to eq 0 }

  describe '#push' do
    Given(:item) { double(OrderItem) }
    Given(:u1) { Pricing::SerialUnit.new(item, 1) }
    Given(:u2) { Pricing::SerialUnit.new(item, 2) }
    Given(:units) { [u1, u2] }
    When { group.push(units) }
    Then { expect(group.size).to eq 2 }
    And { expect(group.units).to match_array(units) }
  end

  context 'about pricing' do
    Given(:item1) { double(OrderItem, selling_price: Price.new(120)) }
    Given(:item2) { double(OrderItem, selling_price: Price.new(250)) }
    Given(:u1_1) { Pricing::SerialUnit.new(item1, 1) }
    Given(:u1_2) { Pricing::SerialUnit.new(item1, 2) }
    Given(:u1_3) { Pricing::SerialUnit.new(item1, 3) }
    Given(:u2_1) { Pricing::SerialUnit.new(item2, 1) }
    Given(:u2_2) { Pricing::SerialUnit.new(item2, 2) }
    Given { group.push([u1_1, u1_2, u1_3, u2_1, u2_2]) }

    describe '#prices_by_item' do
      When(:prices) { group.prices_by_item }
      Then { expect(prices.keys).to match_array([item1, item2]) }
      And { expect(prices[item1]).to be_kind_of(Price) }
      And { expect(prices[item2]).to be_kind_of(Price) }
      And { expect(prices[item1]).to eq 360 }
      And { expect(prices[item2]).to eq 500 }
    end

    describe '#total_price' do
      When(:total) { group.total_price }
      Then { expect(total).to be_kind_of(Price) }
      And { expect(total).to eq 860 }
    end

    describe '#discount_info_by_item' do
      context 'the total discount could be apportion to items completedly' do
        Given { allow(group).to receive(:discount_price).and_return(86) }
        When(:discounts) { group.discount_info_by_item }
        Then { expect(discounts.keys).to match_array([item1, item2]) }
        And { expect(discounts[item1][:price]).to eq 36 }
        And { expect(discounts[item1][:quantity]).to eq 3 }
        And { expect(discounts[item2][:price]).to eq 50 }
        And { expect(discounts[item2][:quantity]).to eq 2 }
      end

      context 'the total discount could not be apportion to items completedly' do
        Given { allow(group).to receive(:discount_price).and_return(100) }
        When(:discounts) { group.discount_info_by_item }
        Then { expect(discounts.keys).to match_array([item1, item2]) }
        And { expect(discounts[item1][:price]).to eq 41 }
        And { expect(discounts[item1][:quantity]).to eq 3 }
        And { expect(discounts[item2][:price]).to eq 59 }
        And { expect(discounts[item2][:quantity]).to eq 2 }
      end
    end
  end

  describe '#discount_price' do
    Given { allow(group).to receive(:total_price).and_return(Price.new(1000)) }

    context 'strategy has fixed discount of 450' do
      Given(:discount_formula) { build :discount_formula, :fixed, price_table: { 'TWD' => 450.0 } }
      Then { expect(group.discount_price).to eq 450 }
    end

    context 'strategy has fixed discount of 1500' do
      Given(:discount_formula) { build :discount_formula, :fixed, price_table: { 'TWD' => 1500.0 } }
      Then { expect(group.discount_price).to eq 1000 }
    end

    context 'strategy has 15% off' do
      Given(:discount_formula) { build :discount_formula, :percentage, percentage: 0.15 }
      Then { expect(group.discount_price).to eq 150 }
    end

    context 'strategy has pay discount of 99' do
      Given(:discount_formula) { build :discount_formula, :pay, price_table: { 'TWD' => 99.0 } }
      Then { expect(group.discount_price.to_f).to eq 1_000 - 99.0 }
    end

    context 'strategy has pay discount of 1500' do
      Given(:discount_formula) { build :discount_formula, :pay, price_table: { 'TWD' => 1500.0 } }
      Then { expect(group.discount_price.to_f).to eq 0 }
    end

    context 'when formula calculation return a number greater than total_price' do
      Given(:discount_formula) { build :discount_formula, :pay, price_table: { 'TWD' => 1500.0 } }
      before { allow(discount_formula).to receive(:calculate).and_return(Price.new(1500)) }
      Then { expect(group.discount_price.to_f).to eq 0 }
    end
  end
end
