# == Schema Information
#
# Table name: notifications
#
#  id                           :integer          not null, primary key
#  message                      :string(255)
#  message_id                   :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  filter                       :json
#  delivery_at                  :datetime
#  deep_link                    :string(255)
#  jid                          :string(255)
#  filter_count                 :integer
#  notification_trackings_count :integer          default(0)
#

require 'rails_helper'

RSpec.describe Notification, type: :model do
  it 'FactoryGirl' do
    expect(build(:notification)).to be_valid
  end

  it { should validate_presence_of(:message) }
  it { should have_many(:notification_trackings) }

  context 'count_filter', :vcr do
    it 'filter is nil' do
      create_list(:device, 5)
      notification = create(:notification)
      expect(notification.filter_count).to eq(5)
    end

    it 'filter country_code_in JP' do
      create_list(:device, 5)
      create(:device, country_code: 'JP')
      notification = create(:notification, filter: { country_code_in: ['JP'] })
      expect(notification.filter_count).to eq(1)
    end
  end

  it 'notification tracking count' do
    notification = create(:notification)
    expect(notification.notification_trackings_count).to eq(0)
    notification.notification_trackings.create
    notification.notification_trackings.create
    notification.notification_trackings.create
    expect(notification.reload.notification_trackings_count).to eq(3)
  end
end
