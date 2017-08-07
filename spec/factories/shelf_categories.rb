# == Schema Information
#
# Table name: shelf_categories
#
#  id          :integer          not null, primary key
#  factory_id  :integer
#  name        :string(255)      not null
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  deleted_at  :datetime
#

FactoryGirl.define do
  factory :shelf_category do
    factory_id { create(:factory).id }
    sequence(:name) { |n| "name#{n}" }
    description 'description'

    trait :scrapped do
      name '报废'
    end
  end
end
