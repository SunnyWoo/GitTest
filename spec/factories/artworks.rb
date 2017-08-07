# == Schema Information
#
# Table name: artworks
#
#  id             :integer          not null, primary key
#  model_id       :integer
#  uuid           :string(255)
#  name           :string(255)
#  description    :text
#  work_type      :integer
#  finished       :boolean          default(FALSE)
#  featured       :boolean          default(FALSE)
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#  user_id        :integer
#  user_type      :string(255)
#  application_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :artwork do
    product { create(:product_model) }
    sequence(:name) { |n| "artwork-#{n}" }
    description { "description of #{name}" }
    user { create :user }

    trait :user_is_designer do
      user { create :designer }
    end
  end
end
