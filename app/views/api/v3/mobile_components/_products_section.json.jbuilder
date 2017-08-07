json.section_title component.contents.section_title
json.section_color component.contents.section_color
json.product_type component.contents.product_type
json.background do
  json.thumb component.image.thumb.url
  json.normal component.image.url
  json.large component.image.url
end
json.products do
  if component.contents.designer_id.present?
    works = component.designer_works
  elsif component.contents.tag_id.present?
    works = component.tag_works
  elsif component.contents.collection_id.present?
    works = component.collection_works
  end
  if works.present?
    json.partial! 'api/v3/mobile_components/products_section_work', collection: works, as: :work, component: component
  else
    json.partial! 'api/v3/mobile_components/products_section_item', collection: component.sub_components, as: :sub
  end
end
