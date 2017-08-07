# == Schema Information
#
# Table name: newsletters
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  delivery_at         :datetime
#  filter              :json
#  subject             :string(255)
#  content             :text
#  locale              :string(255)
#  mailgun_campaign_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#  state               :integer          default(0)
#

require 'rails_helper'

RSpec.describe Newsletter, type: :model do
  it 'FactoryGirl' do
    expect( build(:newsletter) ).to be_valid
  end
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:filter) }
  it { should belong_to(:mailgun_campaign) }
end
