# == Schema Information
#
# Table name: mailgun_campaigns
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  campaign_id       :string(255)
#  is_mailgun_create :boolean          default(FALSE)
#  report            :json
#  created_at        :datetime
#  updated_at        :datetime
#

require 'rails_helper'

RSpec.describe MailgunCampaign, type: :model do
  it 'FactoryGirl' do
    expect( build(:mailgun_campaign) ).to be_valid
  end

  it { should validate_presence_of(:name) }
end
