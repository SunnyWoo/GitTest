# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Fee do
  it 'FactoryGirl' do
    expect( build(:fee) ).to be_valid
  end

end
