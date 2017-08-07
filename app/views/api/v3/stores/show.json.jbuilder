cache_json_for json, @store do
  json.store do
    json.id @store.id
    json.slug @store.slug
    json.avatar @store.avatar.url
    json.title @store.title
    json.description @store.description
  end
end
