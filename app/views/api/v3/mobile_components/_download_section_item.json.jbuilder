json.image do
  json.thumb sub.image.thumb.url
  json.normal sub.image.url
  json.large sub.image.url
end
json.title sub.contents.title
json.download_url sub.contents.download_url

json.partial! 'api/v3/mobile_components/link', sub: sub
