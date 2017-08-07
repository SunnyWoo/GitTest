cache_json_for json, block do
  json.extract!(block, :id, :title, :template, :position)
  json.title_translations full_translations(block.title_translations)
  json.items do
    json.partial! 'api/v3/home_block_item', collection: block.items, as: :item
  end
end
