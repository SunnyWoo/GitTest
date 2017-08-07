require 'spec_helper'

RSpec.describe 'api/v3/notifications/index.json.jbuilder', :caching, type: :view do
  let!(:notification) { create(:notification) }
  let(:notifications) { Notification.page(1) }

  it 'renders notification' do
    assign(:notifications, notifications)
    render
    expect(JSON.parse(rendered)).to eq(
      'notifications' => [{
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
      }],
      'meta' => {
        'pagination' => {
          'current_page' => notifications.current_page,
          'next_page' => notifications.next_page,
          'previous_page' => notifications.previous_page,
          'total_entries' => notifications.total_entries,
          'total_pages' => notifications.total_pages
        }
      }
    )
  end
end
