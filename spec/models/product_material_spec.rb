# == Schema Information
#
# Table name: product_materials
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe ProductMaterial, type: :model do
  it { should validate_length_of(:code).is_equal_to(3) }
  it { should have_many(:products) }

  it 'FactoryGirl' do
    expect(build(:product_craft)).to be_valid
  end

  context 'select_collections' do
    Given!(:material1) { create :product_material }
    Given!(:material2) { create :product_material }
    Given(:collection) do
      {
        "#{material1.code} (#{material1.description})" => material1.id,
        "#{material2.code} (#{material2.description})" => material2.id
      }
    end
    Then { ProductMaterial.select_collections == collection }
  end

  context 'included UpcaseCode' do
    ChannelCode.const_get(:UpcaseCode) == UpcaseCode
  end
end
