json.cache! [cache_key_for_collection(@products)] do
  json.products do
    json.partial! 'api/v3/product_model', collection: @products, as: :product
  end
end
