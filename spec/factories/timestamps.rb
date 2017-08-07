# == Schema Information
#
# Table name: timestamps
#
#  id           :integer          not null, primary key
#  date         :date
#  timestamp_no :integer
#  created_at   :datetime
#  updated_at   :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :timestamp do
    date Date.today
    timestamp_no 001
  end
end
