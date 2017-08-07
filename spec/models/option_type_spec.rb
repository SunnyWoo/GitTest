# == Schema Information
#
# Table name: option_types
#
#  id           :integer          not null, primary key
#  name         :string
#  presentation :string
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe OptionType, type: :model do
  it 'FactoryGirl' do
    expect(build(:option_type)).to be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:presentation) }
  it { should validate_uniqueness_of(:name) }
  it { should have_many(:product_option_types) }
  it { should have_many(:products) }
end
