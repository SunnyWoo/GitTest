cache_json_for json, link do
  json.call(link, :title, :href, :blank, :dropdown, :auto_generate_product)
  json.columns do
    collection = link.children.rows.map { |row| link.children.where(row: row) }
    json.partial! 'api/v3/header_link_row', collection: collection, as: :collection
  end
end
