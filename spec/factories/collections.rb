# == Schema Information
#
# Table name: collections
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :collection do
    sequence(:name) { |n| "Collectoin ##{n}" }
    sequence(:text_en) { |n| "Collectoin ##{n}" }
  end
end
