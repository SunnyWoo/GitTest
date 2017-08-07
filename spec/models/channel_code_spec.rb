# == Schema Information
#
# Table name: channel_codes
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe ChannelCode, type: :model do
  it { should validate_length_of(:code).is_equal_to(3) }

  it 'FactoryGirl' do
    expect(build(:channel_code)).to be_valid
  end

  context 'included UpcaseCode' do
    ChannelCode.const_get(:UpcaseCode) == UpcaseCode
  end
end
