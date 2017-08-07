cache_json_for json, category do
  json.call(category, :id, :name, :available, :packages_count, :downloads_count)
  json.name_translations full_translations(category.name_translations)
  json.packages do
    json.partial! 'api/v3/asset_package', collection: category.packages, as: :package
  end
end
