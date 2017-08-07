# == Schema Information
#
# Table name: purchase_price_tiers
#
#  id          :integer          not null, primary key
#  category_id :integer
#  count_key   :integer
#  price       :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe Purchase::PriceTier, type: :model do
  it 'FactoryGirl' do
    expect(build(:purchase_price_tier)).to be_valid
  end

  context 'validation' do
    it { should validate_presence_of(:count_key) }
    it { should validate_presence_of(:price) }
  end
end
