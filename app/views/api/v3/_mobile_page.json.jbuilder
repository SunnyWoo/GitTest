cache_json_for json, mobile_page do
  json.call(mobile_page, :id, :key, :begin_at, :close_at, :page_type)
  json.components do
    json.partial! 'api/v3/mobile_component', collection: mobile_page.mobile_components, as: :component
  end
end
