# == Schema Information
#
# Table name: timestamps
#
#  id           :integer          not null, primary key
#  date         :date
#  timestamp_no :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

RSpec.describe Timestamp, :type => :model do
  it { should validate_uniqueness_of(:date) }
  it 'FactoryGirl' do
    expect(build(:timestamp)).to be_valid
  end
end
