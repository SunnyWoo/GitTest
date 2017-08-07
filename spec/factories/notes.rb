# == Schema Information
#
# Table name: notes
#
#  id            :integer          not null, primary key
#  message       :text
#  user_id       :integer
#  noteable_id   :integer
#  noteable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  user_type     :string(255)
#

FactoryGirl.define do
  factory :note do
    user { build(:admin) }
    noteable { build(:work) }
    message Faker::Lorem.sentence
  end
end
