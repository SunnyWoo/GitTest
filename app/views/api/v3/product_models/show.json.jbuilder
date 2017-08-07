cache_json_for json, @product do
  json.product_model do
    json.partial! 'api/v3/product_model', product: @product, include_specs: true, include_editor_optimization_images: true
  end
end
