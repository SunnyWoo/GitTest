# == Schema Information
#
# Table name: newsletters
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  delivery_at         :datetime
#  filter              :json
#  subject             :string(255)
#  content             :text
#  locale              :string(255)
#  mailgun_campaign_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#  state               :integer          default(0)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :newsletter do
    sequence(:name) { |n| "newsletter name #{n}" }
    subject Faker::Lorem.sentence
    content Faker::Lorem.paragraph
    filter ['test@test.com']
    locale 'zh'
    delivery_at Time.now + 1.hours
  end
end
