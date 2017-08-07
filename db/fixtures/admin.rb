rows = YAML.load(File.read('db/fixtures/data/admins.yml'))
Admin.seed_once(:email, rows)

rows = YAML.load(File.read('db/fixtures/data/designers.yml'))
Designer.seed_once(:email, rows)
