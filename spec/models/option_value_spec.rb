# == Schema Information
#
# Table name: option_values
#
#  id             :integer          not null, primary key
#  option_type_id :integer
#  name           :string
#  presentation   :string
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe OptionValue, type: :model do
  it 'FactoryGirl' do
    expect(build(:option_value)).to be_valid
  end

  it { should belong_to :option_type }
  it { should have_many :option_value_variants }
  it { should have_many :variants }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:presentation) }
  it { should validate_uniqueness_of(:name).scoped_to(:option_type_id) }
end
