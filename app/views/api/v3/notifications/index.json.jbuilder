json.cache! [cache_key_for_collection(@notifications)] do
  json.notifications do
    json.partial! 'api/v3/notification', collection: @notifications, as: :notification
  end
end
json.meta do
  json.partial! 'api/v3/pagination', models: @notifications
end
