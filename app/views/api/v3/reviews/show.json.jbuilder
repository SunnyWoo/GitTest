cache_json_for json, @review do
  json.review do
    json.partial! 'api/v3/review', review: @review
  end
end
