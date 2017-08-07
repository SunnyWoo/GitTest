json.categories do
  json.array! @categories do |category, products|
    json.extract!(category, :id, :key, :name)
    json.images do
      json.s80 category.image.s80.url
      json.s160 category.image.s160.url
    end

    json.models do
      json.array! products do |product|
        json.call(product, :id, :key, :name, :description, :prices,
                  :customized_special_prices, :design_platform,
                  :customize_platform)
        json.placeholder_image product.placeholder_image.url
      end
    end
  end
end
json.meta do
  json.category_count @categories.size
  json.product_model_count @categories.map { |_, products| products.size }.sum
end
