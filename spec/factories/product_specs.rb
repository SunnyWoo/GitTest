# == Schema Information
#
# Table name: product_specs
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :product_spec do
    description 'spec'
    sequence(:code) { |n| "#{n}" }
  end
end
