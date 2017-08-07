json.title component.contents.title
json.background do
  json.thumb component.image.thumb.url
  json.normal component.image.url
  json.large component.image.url
end
json.items do
  json.partial! 'api/v3/mobile_components/create_section_item', collection: component.sub_components, as: :sub
end
