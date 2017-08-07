# == Schema Information
#
# Table name: campaigns
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  key                :string(255)
#  title              :string(255)
#  desc               :string(255)
#  designer_username  :string(255)
#  artworks_class     :string(255)
#  wordings           :json
#  about_designer     :text
#  created_at         :datetime
#  updated_at         :datetime
#  aasm_state         :string(255)      default("is_closed")
#  google_calendar_id :string(255)
#

FactoryGirl.define do
  factory :campaign do
    name Faker::Lorem.word
    key Faker::Lorem.word
    title Faker::Lorem.word
    desc Faker::Lorem.sentence
    designer_username Faker::Lorem.word
    artworks_class Faker::Lorem.word
    about_designer Faker::Lorem.sentence
  end
end
