cache_json_for json, link do
  json.call(link, :title, :href, :blank, :link_type, :spec_id, :auto_generate_product)
  json.tags do
    json.partial! 'api/v3/header_link_tag', collection: link.tags, as: :tag
  end
end
