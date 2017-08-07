require 'spec_helper'

RSpec.describe 'api/v3/_notification.json.jbuilder', :caching, type: :view do
  let(:notification) { create(:notification) }

  it 'renders notification' do
    render 'api/v3/notification', notification: notification
    expect(JSON.parse(rendered)).to eq(
      'id' => notification.id,
      'created_at' => notification.created_at.as_json,
      'message' => notification.message,
      'status' => notification.status,
      'is_sent' => notification.message_id.present?,
      'delivery_at' => notification.delivery_at.as_json,
      'notification_trackings_count' => notification.notification_trackings_count,
      'filter' => notification.filter,
      'deep_link' => notification.deep_link,
      'filter_count' => notification.filter_count
    )
  end
end
