json.extract!(product_category, :id, :key, :name)
json.images do
  json.s80 product_category.image.s80.url
  json.s160 product_category.image.s160.url
end
json.models do
  json.array! products do |product|
    json.partial! 'api/v3/product_model', product: product, include_specs: true
  end
end