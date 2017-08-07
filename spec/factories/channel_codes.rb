# == Schema Information
#
# Table name: channel_codes
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :channel_code do
    description 'description'
    sequence(:code) { |n| "co#{n}" }
  end
end
