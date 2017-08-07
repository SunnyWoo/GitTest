json.cache! [cache_key_for_collection(@previews)] do
  json.work do
    json.ready @previews.all? { |preview| preview.image.url }
    json.previews do
      json.partial! 'api/v3/preview', collection: @previews, as: :preview
    end
  end
end
