return if Rails.env.test?
require 'seed-fu'

rows = YAML.load(File.read('db/fixtures/data/currency_types.yml'))
CurrencyType.seed_once(:code, rows)
