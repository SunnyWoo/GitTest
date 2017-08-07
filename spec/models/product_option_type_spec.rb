# == Schema Information
#
# Table name: product_option_types
#
#  id             :integer          not null, primary key
#  product_id     :integer
#  option_type_id :integer
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe ProductOptionType, type: :model do
  it 'FactoryGirl' do
    expect(build(:option_type)).to be_valid
  end

  it { should belong_to(:product) }
  it { should belong_to(:option_type) }
end
