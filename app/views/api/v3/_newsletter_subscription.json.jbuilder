cache_json_for json, newsletter_subscription do
  json.extract!(newsletter_subscription, :id, :email)
end
