return if Rails.env.test?

require 'seed-fu'

rows = YAML.load(File.read('db/fixtures/data/product_categories.yml'))
rows.each do |row|
  row['category_code_id'] = ProductCategoryCode.find_by(code: row['category_code']).try(:id)
  row.delete('category_code')
end
ProductCategory.seed_once(:key, rows)

rows = YAML.load(File.read('db/fixtures/data/product_category_translations.yml'))
rows.each do |key, array_values|
  product_category_id = ProductCategory.find_by(key: key).id
  array_values.each { |row| row['product_category_id'] = product_category_id }
  ProductCategory::Translation.seed_once(:product_category_id, :locale, array_values)
end
