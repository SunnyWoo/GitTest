json.cache! [cache_key_for_collection(@reviews)] do
  json.reviews do
    json.partial! 'api/v3/review', collection: @reviews, as: :review
  end
end
json.meta do
  json.reviews_count @reviews.count
end
