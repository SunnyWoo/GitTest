# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  token           :string(255)
#  detail          :text
#  os_version      :string(255)
#  device_type     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  endpoint_arn    :string(255)
#  country_code    :string(255)
#  timezone        :string(255)
#  is_enabled      :boolean          default(TRUE)
#  getui_client_id :string(255)
#  idfa            :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :device do
    os_version "OS_#{Random.rand(9..99).ceil}"
    device_type 'iOS'
    token { SecureRandom.hex }
    endpoint_arn { SecureRandom.hex }
    country_code 'TW'
    timezone 'Taipei'
    idfa { SecureRandom.hex }
    getui_client_id { SecureRandom.hex }
  end
end
