json.cache! [@presenter.cache_key] do
  json.categories do
    json.array! @presenter do |category, products|
      json.partial! 'api/v3/product_category', product_category: category, products: products
    end
  end
  json.meta do
    json.category_count @presenter.size
    json.product_model_count @presenter.map { |_, products| products.size }.sum
    json.platform platform
    json.scope scope
  end
end
