FactoryGirl.define do
  factory :shipping_info do
    address Faker::Address.street_address + Faker::Address.secondary_address
    city Faker::Address.city
    name Faker::Name.name
    phone Faker::PhoneNumber.phone_number
    state Faker::AddressUS.state
    zip_code Faker::AddressUS.zip_code
    country Faker::Address.country('US')
    country_code 'US'
    email Faker::Internet.free_email
    province
  end
end
