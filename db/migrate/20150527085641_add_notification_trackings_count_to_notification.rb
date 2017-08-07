class AddNotificationTrackingsCountToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :notification_trackings_count, :integer, default: 0
  end
end
