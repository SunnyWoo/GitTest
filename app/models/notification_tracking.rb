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
class NotificationTracking < ActiveRecord::Base
  store_accessor :extra_info, :ip, :os_type, :os_version, :device_model,
                 :app_version
  validates :notification_id, presence: true
  belongs_to :notification, counter_cache: true
  belongs_to :user
end
