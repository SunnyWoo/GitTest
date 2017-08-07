json.cache! [cache_key_for_collection(@home_slides)] do
  json.home_slides do
    json.partial! 'api/v3/home_slide', collection: @home_slides, as: :home_slide
  end
end
