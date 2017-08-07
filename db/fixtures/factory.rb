require 'seed-fu'
rows = YAML.load(File.read('db/fixtures/data/factories.yml'))
Factory.seed_once(:code, rows)

FactoryMember.seed_once(:email) do |s|
  s.username = 'commandp'
  s.email = 'calgary1986@gmail.com'
  s.password = 'commandp'
  s.factory_id = Factory.find_by(code: 'commandp').id
end

FactoryMember.seed_once(:email) do |s|
  s.username = 'wonder'
  s.email = 'wonder@dummyemail.com'
  s.password = 'wonder'
  s.factory_id = Factory.find_by(code: 'wonder').id
end
