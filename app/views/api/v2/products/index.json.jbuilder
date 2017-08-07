cache_key = categories.map do |rows|
  [rows[0].cache_key, rows[1].map(&:cache_key).join].join
end.join

json.cache! ['v2', Digest::MD5.hexdigest(cache_key)] do
  json.categories do
    json.array! categories do |category, products|
      json.partial! 'api/v2/products/category', product_category: category, products: products
    end
  end
end

json.meta do
  json.category_count categories.size
  json.product_model_count categories.map { |_, products| products.size }.sum
  json.platform platform
  json.scope scope
end
