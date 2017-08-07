json.items do
  json.partial! 'api/v3/mobile_components/description_section_item', collection: component.sub_components, as: :sub
end
