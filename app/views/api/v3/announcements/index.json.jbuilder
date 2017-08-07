json.cache! [cache_key_for_collection(@announcements)] do
  json.announcements do
    json.partial! 'api/v3/announcement', collection: @announcements, as: :announcement
  end
end
