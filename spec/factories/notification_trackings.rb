# == Schema Information
#
# Table name: notification_trackings
#
#  id              :integer          not null, primary key
#  notification_id :integer
#  user_id         :integer
#  device_token    :string(255)
#  country_code    :string(255)
#  opened_at       :datetime
#  extra_info      :hstore
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :notification_tracking do
    notification { create(:notification) }
    user { create :user }
    opened_at Time.zone.now
  end

end
