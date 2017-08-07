# == Schema Information
#
# Table name: provinces
#
#  id         :integer          not null, primary key
#  area_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  code       :string(2)
#

FactoryGirl.define do
  factory :province do
    sequence(:name) { |n| "Province_#{n}" }
  end
end
