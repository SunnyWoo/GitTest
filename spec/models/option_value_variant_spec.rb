# == Schema Information
#
# Table name: option_value_variants
#
#  id              :integer          not null, primary key
#  variant_id      :integer
#  option_value_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe OptionValueVariant, type: :model do
  it 'FactoryGirl' do
    expect(build(:option_value_variant)).to be_valid
  end

  it { should belong_to(:option_value) }
  it { should belong_to(:variant) }
end
