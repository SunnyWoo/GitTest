code_klasses = [ProductCategoryCode, ProductCraft, ProductMaterial, ProductSpec]

code_klasses.each do |klass|
  rows = YAML.load(File.read("db/fixtures/data/codes/#{klass.table_name}.yml"))
  klass.seed_once(:code, rows)
end
