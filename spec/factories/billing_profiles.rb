# == Schema Information
#
# Table name: billing_profiles
#
#  id            :integer          not null, primary key
#  address       :text
#  city          :string(255)
#  name          :string(255)
#  phone         :string(255)
#  state         :string(255)
#  zip_code      :string(255)
#  country       :string(255)
#  billable_id   :integer
#  billable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  country_code  :string(255)
#  shipping_way  :integer          default(0)
#  email         :string(255)
#  type          :string(255)
#  address_name  :string(255)
#  memo          :hstore
#  province_id   :integer
#  address_data  :json
#

FactoryGirl.define do
  factory :billing_profile do
    address Faker::Address.street_address + Faker::Address.secondary_address
    city Faker::Address.city
    name Faker::Name.name
    phone Faker::PhoneNumber.phone_number
    state Faker::AddressUS.state
    zip_code Faker::AddressUS.zip_code
    country_code 'US'
    email Faker::Internet.free_email
  end
end
