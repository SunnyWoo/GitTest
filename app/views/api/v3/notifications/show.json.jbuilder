cache_json_for json, @notification do
  json.notification do
    json.partial! 'api/v3/notification', notification: @notification
  end
end
