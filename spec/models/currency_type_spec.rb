# == Schema Information
#
# Table name: currency_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  code        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  rate        :float            default(1.0)
#  precision   :integer          default(0)
#

require 'spec_helper'

describe CurrencyType do
  before { CurrencyType.delete_all }

  it 'FactoryGirl' do
    expect(build(:currency_type)).to be_valid
  end
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:rate) }
  it { should validate_uniqueness_of(:code) }

  describe '.by_country' do
    it 'returns correct currency code' do
      expect(CurrencyType.by_country('TW')).to eq('TWD')
      expect(CurrencyType.by_country('CN')).to eq('CNY')
      expect(CurrencyType.by_country('JP')).to eq('JPY')
      expect(CurrencyType.by_country('HK')).to eq('HKD')
    end

    context 'default' do
      Then { CurrencyType.by_country('unknown') == Region.default_currency }
    end
  end

  context 'after create currency type' do
    it 'return true when check fee currencies' do
      fee = create(:fee)
      create(:currency_type, name: 'JPY', code: 'JPY')
      currency = fee.tap(&:reload).currencies.find_by(code: 'JPY')
      expect(currency).not_to be_nil
      expect(currency.price).not_to be_nil
    end

    it 'update price tier' do
      price_tier = create(:price_tier)
      create(:currency_type, name: 'JPY', code: 'JPY', rate: 0.25)
      expect(price_tier.tap(&:reload).prices['JPY']).to eq(1200)
    end
  end
end
