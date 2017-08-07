# == Schema Information
#
# Table name: bdevents
#
#  id         :integer          not null, primary key
#  uuid       :string(255)
#  starts_at  :datetime
#  ends_at    :datetime
#  priority   :integer          default(1)
#  is_enabled :boolean
#  event_type :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#  background :string(255)
#

FactoryGirl.define do
  factory :bdevent do
    uuid UUIDTools::UUID.timestamp_create.to_s
    starts_at Time.zone.yesterday
    ends_at Time.zone.tomorrow
    event_type :event
    priority 1
    is_enabled true
    after(:build) do |object|
      tmp = object.translations.build(locale: 'zh-TW')
      tmp.title = 'title'
      tmp.desc = 'desc'
      tmp.banner = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')
      tmp.coming_soon_image = fixture_file_upload('spec/photos/test.jpg', 'image/jpeg')
      tmp.ticker = 'this is ticker'
    end
  end
end
