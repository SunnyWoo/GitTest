cache_json_for json, notification do
  json.extract!(notification, :id, :created_at, :message, :status)
  json.is_sent notification.message_id.present?
  json.extract!(notification, :delivery_at, :notification_trackings_count,
                :filter, :deep_link, :filter_count)
end
