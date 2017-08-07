# == Schema Information
#
# Table name: product_specs
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe ProductSpec, type: :model do
  it { should validate_length_of(:code).is_equal_to(1) }
  it { should have_many(:products) }

  it 'FactoryGirl' do
    expect(build(:product_spec)).to be_valid
  end

  context 'select_collections' do
    Given!(:spec1) { create :product_spec }
    Given!(:spec2) { create :product_spec }
    Given(:collection) do
      {
        "#{spec1.code} (#{spec1.description})" => spec1.id,
        "#{spec2.code} (#{spec2.description})" => spec2.id
      }
    end
    Then { ProductSpec.select_collections == collection }
  end

  context 'included UpcaseCode' do
    ChannelCode.const_get(:UpcaseCode) == UpcaseCode
  end
end
