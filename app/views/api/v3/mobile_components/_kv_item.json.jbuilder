json.image do
  json.thumb sub.image.thumb.url
  json.normal sub.image.url
  json.large sub.image.url
end
json.action_type sub.contents.action_type
json.action_target sub.contents.action_target
json.action_key sub.contents.action_key
