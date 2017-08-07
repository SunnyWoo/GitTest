json.product_categories @categories do |category|
  json.extract!(category, :id, :key, :name)
end
