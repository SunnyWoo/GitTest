# == Schema Information
#
# Table name: newsletter_subscriptions
#
#  id           :integer          not null, primary key
#  email        :string(255)
#  locale       :string(255)
#  is_enabled   :boolean          default(TRUE)
#  created_at   :datetime
#  updated_at   :datetime
#  country_code :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :newsletter_subscription do
    sequence(:email) { |n| "mail#{n}@commandp.me" }
    locale :zh
    country_code 'TW'
  end
end
