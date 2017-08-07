# == Schema Information
#
# Table name: option_types
#
#  id           :integer          not null, primary key
#  name         :string
#  presentation :string
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :option_type do
    sequence(:name) { |n| "name-#{n}" }
    presentation 'presentation'
  end
end
