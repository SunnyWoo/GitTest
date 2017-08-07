json.cache! [cache_key_for_collection(@works)] do
  json.works do
    json.partial! 'api/v3/work', collection: @works, as: :work
  end
end
json.meta do
  json.request_query @request_query
  json.current_page_count @works.count
  json.current_page @works.current_page
  json.per_page @works.per_page
  json.total_count @works.total_entries
  json.total_pages @works.total_pages
end
