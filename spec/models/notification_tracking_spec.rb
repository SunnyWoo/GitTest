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

require 'rails_helper'

RSpec.describe NotificationTracking, type: :model do
  it 'FactoryGirl' do
    expect(build(:notification_tracking)).to be_valid
  end
  it { should validate_presence_of(:notification_id) }
end
