# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  content    :text
#  is_admin   :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Comment do
  it 'FactoryGirl' do 
    expect( build(:comment) ).to be_valid
  end
end
