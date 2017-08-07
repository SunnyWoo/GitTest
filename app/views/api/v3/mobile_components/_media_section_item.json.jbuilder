json.image do
  json.thumb sub.image.thumb.url
  json.normal sub.image.url
  json.large sub.image.url
end
json.title sub.contents.title
json.content sub.contents.content
json.media_type sub.contents.media_type
json.tab_category sub.contents.tab_category
json.media_url sub.contents.media_url
json.action_text sub.contents.action_text
json.action_type sub.contents.action_type
json.action_target sub.contents.action_target
json.action_key sub.contents.action_key
