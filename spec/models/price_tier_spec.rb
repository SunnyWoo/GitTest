# == Schema Information
#
# Table name: price_tiers
#
#  id          :integer          not null, primary key
#  tier        :integer
#  prices      :json
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(255)
#

require 'rails_helper'

RSpec.describe PriceTier, type: :model do
  it 'FactoryGirl' do
    expect( build(:price_tier) ).to be_valid
  end

  describe '#initialize' do
    it 'stores data from frontend correctly' do
      tier = { 'tier' => 1, TWD: 10, HKD:  5, JPY: 30 }
      price_tier = PriceTier.create!(data: tier)
      expect(price_tier.tier).to eq(1)
      expect(price_tier.prices.keys).to eq(%w(TWD HKD JPY))
      expect(price_tier.prices.values).to eq([10, 5, 30])
    end
  end

  describe '#as_json' do
    it 'returns correct hash' do
      tier = { 'tier' => 1, TWD: 10, HKD:  5, JPY: 30, 'description' => "I'm fake!" }
      price_tier = PriceTier.create!(data: tier)
      expect(price_tier.as_json).to eq('tier' => 1, 'TWD' => 10, 'HKD' => 5, 'JPY' => 30, 'id' => price_tier.id, 'description' => "I'm fake!")
    end
  end

  describe '#validate_all_prices_are_present' do
    context 'when all prices are present' do
      it 'does not add error to prices' do
        tier = { 'tier' => 1, TWD: 10, HKD:  5, JPY: 30 }
        price_tier = PriceTier.create(data: tier)
        expect(price_tier.errors[:prices]).to be_empty
      end
    end

    context 'when any prices are blank' do
      it 'adds error to prices' do
        tier = { 'tier' => 1, TWD: nil, HKD:  5, JPY: 30 }
        price_tier = PriceTier.create(data: tier)
        expect(price_tier.errors[:prices]).to include(I18n.t('errors.messages.blank'))
      end
    end
  end

  describe '#validate_all_prices_are_positive' do
    context 'when all prices are positive' do
      it 'does not add error to prices' do
        tier = { 'tier' => 1, TWD: 10, HKD:  5, JPY: 30 }
        price_tier = PriceTier.create(data: tier)
        expect(price_tier.errors[:prices]).to be_empty
      end
    end

    context 'when any prices are negative' do
      it 'adds error to prices' do
        tier = { 'tier' => 1, TWD: -10, HKD:  5, JPY: 30 }
        price_tier = PriceTier.create(data: tier)
        expect(price_tier.errors[:prices]).to include(/can't be negative/)
      end
    end
  end

  describe '#validate_all_prices_are_increasing' do
    context 'when price tiers is empty' do
      it 'does not add error to prices' do
        tier = { 'tier' => 1, TWD: 10, HKD:  5, JPY: 30 }
        price_tier = PriceTier.create(data: tier)
        expect(price_tier.errors[:prices]).to be_empty
      end
    end
  end
end
