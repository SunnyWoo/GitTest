# == Schema Information
#
# Table name: mobile_campaigns
#
#  id            :integer          not null, primary key
#  kv            :string(255)
#  title         :string(255)
#  desc_short    :string(255)
#  ticker        :string(255)
#  campaign_type :string(255)
#  publish_at    :datetime
#  starts_at     :datetime
#  ends_at       :datetime
#  is_enabled    :boolean          default(FALSE)
#  position      :integer
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :mobile_campaign do
    campaign_type 'limited_time'
    publish_at Time.zone.now - 2.days
    starts_at Time.zone.yesterday
    ends_at Time.zone.tomorrow
    after(:build) do |object|
      tmp = object.translations.build(locale: 'zh-TW')
      tmp.kv = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')
      tmp.title = Faker::LoremCN.word
      tmp.desc_short = Faker::LoremCN.word
      tmp.ticker = Faker::LoremCN.word
    end
  end
end
