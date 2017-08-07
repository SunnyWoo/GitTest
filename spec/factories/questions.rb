# == Schema Information
#
# Table name: questions
#
#  id                   :integer          not null, primary key
#  question             :string(255)
#  answer               :text
#  question_category_id :integer
#  created_at           :datetime
#  updated_at           :datetime
#

FactoryGirl.define do
  factory :question do
    question Faker::Lorem.sentence
    question_category { create :question_category }
  end
end
