FactoryGirl.define do
  factory :billing_info do
    address Faker::Address.street_address + Faker::Address.secondary_address
    city Faker::Address.city
    name Faker::Name.name
    sequence(:phone) { |n| "091000012#{n}" }
    state Faker::AddressUS.state
    zip_code Faker::AddressUS.zip_code
    country Faker::Address.country('US')
    country_code 'US'
    email Faker::Internet.free_email
    shipping_way 'standard'
  end
end
