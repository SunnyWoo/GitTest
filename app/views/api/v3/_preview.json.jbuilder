# TODO: unify preview json format
cache_json_for json, preview do
  json.id preview.id
  # these used in _work.json.jbuilder
  json.normal preview.image.url
  json.thumb preview.image.thumb.url

  # these used in work previews api
  json.key preview.key
  json.url preview.image.url

  # these used in standardized work api
  json.image_url preview.image.url
  json.position preview.position
end
