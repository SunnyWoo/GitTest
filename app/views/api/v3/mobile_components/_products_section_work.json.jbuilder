json.image do
  order_image = Monads::Optional.new(work.order_image)
  json.thumb order_image.thumb.url.value
  json.normal order_image.url.value
  json.large order_image.url.value
end
json.gid work.to_gid_param
json.uuid work.uuid
json.title work.name
json.description work.product_name
json.original_price work.product.prices
json.price work.prices
json.tip_text component.contents_tip_text
json.will_sale_text component.contents_will_sale_text
json.on_sale_text component.contents_on_sale_text
json.action_type 'shop'
json.action_target nil
json.action_key work.uuid

json.partial! 'api/v3/work', work: work
