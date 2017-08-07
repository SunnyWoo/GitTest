cache_json_for json, @newsletter_subscription do
  json.newsletter_subscription do
    json.partial! 'api/v3/newsletter_subscription', newsletter_subscription: @newsletter_subscription
  end
end
