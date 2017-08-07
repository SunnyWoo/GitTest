campaign = sub.campaign
json.image do
  json.thumb sub.image.thumb.url
  json.normal sub.image.url
  json.large sub.image.url
end
json.page_type campaign.page_type
json.title sub.contents.title
json.description sub.contents.desc_short
json.action_text sub.contents.action_text
json.key campaign.key
json.begin_at campaign.begin_at
json.close_at campaign.close_at
json.limited_count 0
