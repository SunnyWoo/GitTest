# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  name       :string(255)
#

FactoryGirl.define do
  factory :tag do
    sequence(:name) { |n| "Tag_#{n}" }
    sequence(:text_en) { |n| "Tag ##{n}" }
  end
end
