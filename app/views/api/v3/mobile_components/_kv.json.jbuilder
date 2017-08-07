json.items do
  json.partial! 'api/v3/mobile_components/kv_item', collection: component.sub_components, as: :sub
end
