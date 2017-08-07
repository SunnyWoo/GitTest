# == Schema Information
#
# Table name: option_values
#
#  id             :integer          not null, primary key
#  option_type_id :integer
#  name           :string
#  presentation   :string
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :option_value do
    option_type { create :option_type }
    sequence(:name) { |n| "name-#{n}" }
    presentation 'presentation'
  end
end
