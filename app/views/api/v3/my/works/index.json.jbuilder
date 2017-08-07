json.cache! [cache_key_for_collection(@works)] do
  json.works do
    json.partial! 'api/v3/work', collection: @works, as: :work
  end
end
json.meta do
  json.works_count @works.count
end
