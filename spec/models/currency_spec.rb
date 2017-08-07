# == Schema Information
#
# Table name: currencies
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  code             :string(255)
#  price            :float
#  product_model_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  coupon_id        :integer
#  payable_id       :integer
#  payable_type     :string(255)
#

require 'spec_helper'

describe Currency do
  it 'FactoryGirl' do
    expect( build(:currency) ).to be_valid
  end

  before { CurrencyType.delete_all }

  describe '.missing_any_currencies?' do
    it 'returns is missing_currencies any or not' do
      create(:currency_type, code: 'USD')
      create(:currency_type, code: 'TWD')
      create(:currency, code: 'TWD')
      expect(Currency).to be_missing_any_currencies
    end
  end

  describe '.missing_currencies' do
    it 'returns missing currencies' do
      create(:currency_type, code: 'USD')
      create(:currency_type, code: 'TWD')
      create(:currency, code: 'TWD')
      expect(Currency.missing_currencies).to eq(['USD'])
    end
  end
end
