cache_json_for json, package do
  json.extract!(package, :id, :name)
  json.name_translations full_translations(package.name_translations)
  json.extract!(package, :description)
  json.description_translations full_translations(package.description_translations)
  json.extract!(package, :available, :designer_id, :category_id, :begin_at,
                :end_at, :countries, :position, :downloads_count, :category_name)
  json.icon package.icon.url
  if package.designer.present?
    json.designer do
      json.partial! 'api/v3/designer', designer: package.designer
    end
  end
end
