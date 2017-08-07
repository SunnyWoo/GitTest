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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailgun_campaign do
    name 'campaign_name'
  end
end
