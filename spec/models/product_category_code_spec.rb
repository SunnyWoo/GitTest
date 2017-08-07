# == Schema Information
#
# Table name: product_category_codes
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe ProductCategoryCode, type: :model do
  it { should validate_length_of(:code).is_equal_to(2) }
  it { should have_many(:products) }
  it { should have_one(:category) }
  it { is_expected.to have_one :category }

  it 'FactoryGirl' do
    expect(build(:product_category_code)).to be_valid
  end

  context 'included UpcaseCode' do
    ChannelCode.const_get(:UpcaseCode) == UpcaseCode
  end
end
