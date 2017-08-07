# == Schema Information
#
# Table name: product_crafts
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :product_craft do
    description 'craft'
    sequence(:code) { |n| "#{n}" }
  end
end
