# == Schema Information
#
# Table name: variants
#
#  id         :integer          not null, primary key
#  product_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Variant, type: :model do
  it 'FactoryGirl' do
    expect(build(:variant)).to be_valid
  end

  it { should belong_to(:product) }
  it { should have_many(:option_value_variants) }
  it { should have_many(:option_values) }
end
