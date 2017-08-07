# == Schema Information
#
# Table name: file_gateways
#
#  id           :integer          not null, primary key
#  type         :string(255)
#  factory_id   :integer
#  connect_info :hstore
#  created_at   :datetime
#  updated_at   :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :file_gateway do
    factory_id { create(:factory).id }
    connect_info 'bla'
  end
end
