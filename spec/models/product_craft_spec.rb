# == Schema Information
#
# Table name: product_crafts
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe ProductCraft, type: :model do
  it { should validate_length_of(:code).is_equal_to(1) }
  it { should have_many(:products) }

  it 'FactoryGirl' do
    expect(build(:product_craft)).to be_valid
  end

  context 'select_collections' do
    Given!(:product_craft1) { create :product_craft }
    Given!(:product_craft2) { create :product_craft }
    Given(:collection) do
      {
        "#{product_craft1.code} (#{product_craft1.description})" => product_craft1.id,
        "#{product_craft2.code} (#{product_craft2.description})" => product_craft2.id
      }
    end
    Then { ProductCraft.select_collections == collection }
  end

  context 'included UpcaseCode' do
    ChannelCode.const_get(:UpcaseCode) == UpcaseCode
  end
end
