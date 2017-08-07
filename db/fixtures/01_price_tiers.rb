rows = YAML.load(File.read('db/fixtures/data/price_tiers.yml'))
PriceTier.seed_once(:tier, rows)
