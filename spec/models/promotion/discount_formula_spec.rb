require 'spec_helper'

describe Promotion::DiscountFormula do
  Given(:price_tier) { create :price_tier, prices: { 'TWD' => '300.0', 'USD' => '10.0' } }
  Given(:formula) { Promotion::DiscountFormula.new(parameters) }
  context 'for type of fixed' do
    Given(:parameters) do
      {
        "discount_type" => "fixed",
        "price_tier_id" => price_tier.id,
      }
    end

    Then { expect(formula.binded_price).to eq Price.new(300) }
    And { expect(formula.binded_price_tier).to eq price_tier }

    describe '#fixed?' do
      Then { expect(formula.fixed?).to eq true }
    end

    describe '#calculate!' do
      context 'when price is above 300' do
        Given(:price) { Price.new(450) }
        When(:result) { formula.calculate!(price) }
        Then { expect(result).to eq Price.new(150) }
      end
      context 'when price is below 300' do
        Given(:price) { Price.new(200) }
        When(:result) { formula.calculate!(price) }
        Then { expect(result).to eq Price.new(0) }
      end
    end
  end

  context 'for type of percentage' do
    Given(:parameters) do
      {
        "discount_type" => "percentage",
        "percentage" => '0.1',
      }
    end

    Then { expect(formula.percentage).to eq 0.1 }

    describe '#percentage?' do
      Then { expect(formula.percentage?).to eq true }
    end

    describe '#calculate!' do
      Given(:price) { Price.new(450) }
      When(:result) { formula.calculate!(price) }
      Then { expect(result).to eq Price.new(405) }
    end
  end

  context 'for type of pay' do
    Given(:parameters) do
      {
        "discount_type" => "pay",
        "price_tier_id" => price_tier.id,
      }
    end

    Then { expect(formula.binded_price).to eq Price.new(300) }
    And { expect(formula.binded_price_tier).to eq price_tier }

    describe '#pay?' do
      Then { expect(formula.pay?).to eq true }
    end

    describe '#calculate!' do
      context 'when price is above 300' do
        Given(:price) { Price.new(450) }
        When(:result) { formula.calculate!(price) }
        Then { expect(result).to eq Price.new(300) }
      end

      context 'when price is below 300' do
        Given(:price) { Price.new(200) }
        When(:result) { formula.calculate!(price) }
        Then { expect(result).to eq Price.new(200) }
      end
    end
  end

  context 'for type of none' do
    Given(:parameters) do
      {
        "discount_type" => "none",
      }
    end

    describe '#calculate!' do
      context 'when price is 300' do
        Given(:price) { Price.new(300) }
        When(:result) { formula.calculate!(price) }
        Then { expect(result).to eq Price.new(0) }
      end
    end

    describe '#difference!' do
      context 'when price is above 300' do
        Given(:price) { Price.new(300) }
        When(:result) { formula.calculate!(price) }
        Then { expect(result).to eq Price.new(0) }
      end
    end
  end

  describe '#calculate' do
    Given(:parameters) do
      {
        "discount_type" => "pay",
        "price_tier_id" => price_tier_id,
      }
    end

    context 'with nil as argument' do
      Given(:price) { nil }
      Given(:price_tier_id) { price_tier.id }
      When(:result) { formula.calculate(price) }
      Then { expect(result).to eq nil }
    end

    context 'with invalid price_tier as rule params' do
      Given(:price) { Price.new(450) }
      Given(:price_tier_id) { 0 }
      When(:result) { formula.calculate(price) }
      Then { expect(result).to eq price }
    end
  end
end
