# == Schema Information
#
# Table name: header_link_tags
#
#  id             :integer          not null, primary key
#  header_link_id :integer
#  style          :string(255)
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe HeaderLinkTag, type: :model do
  it 'FactoryGirl' do
    expect(build(:header_link_tag)).to be_valid
  end
end
