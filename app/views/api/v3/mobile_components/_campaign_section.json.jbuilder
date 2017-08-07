json.section_title component.contents.section_title
json.section_color component.contents.section_color
json.campaigns do
  json.partial! 'api/v3/mobile_components/campaign', collection: component.sub_components, as: :sub
end
