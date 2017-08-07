work = sub.work

json.image do
  json.thumb sub.image.thumb.url
  json.normal sub.image.url
  json.large sub.image.url
end
json.gid work.to_gid_param
json.uuid work.uuid
json.title sub.contents.title
json.description sub.contents.desc_short
json.original_price work.product.prices
json.price work.prices
json.tip_text sub.contents.tip_text.to_s
json.will_sale_text sub.contents.will_sale_text
json.on_sale_text sub.contents.on_sale_text
json.action_type sub.contents.action_type
json.action_target sub.contents.action_target
json.action_key sub.contents.action_key

json.partial! 'api/v3/work', work: work
