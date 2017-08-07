json.id mobile_page_preview.mobile_page_id
json.call(mobile_page_preview, :key, :begin_at, :close_at, :page_type)
json.components do
  json.partial! 'api/v3/mobile_component_preview', collection: mobile_page_preview.mobile_components, as: :component
end
