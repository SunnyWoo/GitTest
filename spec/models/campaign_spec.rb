# == Schema Information
#
# Table name: campaigns
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  key                :string(255)
#  title              :string(255)
#  desc               :string(255)
#  designer_username  :string(255)
#  artworks_class     :string(255)
#  wordings           :json
#  about_designer     :text
#  created_at         :datetime
#  updated_at         :datetime
#  aasm_state         :string(255)      default("is_closed")
#  google_calendar_id :string(255)
#

require 'rails_helper'

RSpec.describe Campaign, type: :model do
  %i(name key title desc designer_username).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it 'FactoryGirl' do
    expect(build(:campaign)).to be_valid
  end
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:key) }
  it { should validate_uniqueness_of(:key) }
  it { should validate_presence_of(:title) }
end
