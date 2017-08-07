# == Schema Information
#
# Table name: banners
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  image      :string(255)
#  image_meta :text
#  begin_on   :date
#  end_on     :date
#  countries  :string(255)      default([]), is an Array
#  created_at :datetime
#  updated_at :datetime
#  deeplink   :string(255)
#  platforms  :string(255)      default([]), is an Array
#  url        :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :banner do
    sequence(:name) { |n| "Banner #{n}" }
    begin_on { Date.today }
    end_on { Date.today }
    platforms ['iOS', 'Android']
  end
end
