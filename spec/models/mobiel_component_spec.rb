# == Schema Information
#
# Table name: mobile_components
#
#  id             :integer          not null, primary key
#  mobile_page_id :integer
#  key            :string(255)
#  parent_id      :integer
#  position       :integer
#  image          :string(255)
#  contents       :json             default({})
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe MobileComponent, type: :model do
  it 'FactoryGirl' do
    expect(build(:mobile_component)).to be_valid
  end
end
