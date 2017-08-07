# == Schema Information
#
# Table name: product_materials
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :product_material do
    description 'material'
    sequence(:code) { |n| "co#{n}" }
  end
end
