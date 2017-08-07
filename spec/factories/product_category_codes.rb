# == Schema Information
#
# Table name: product_category_codes
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :product_category_code do
    description 'category_code'
    sequence(:code) { |n| "c#{n}" }
  end
end
