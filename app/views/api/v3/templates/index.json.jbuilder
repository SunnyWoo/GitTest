json.cache! [cache_key_for_collection(@templates)] do
  json.templates do
    json.partial! 'api/v3/template', collection: @templates, as: :template
  end
end
json.meta do
  json.templates_count @templates.count
end
