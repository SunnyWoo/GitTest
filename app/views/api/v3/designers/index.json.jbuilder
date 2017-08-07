json.cache! [cache_key_for_collection(@designers)] do
  json.designers do
    json.partial! 'api/v3/designer', collection: @designers, as: :designer
  end
end
