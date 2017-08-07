# == Schema Information
#
# Table name: site_settings
#
#  id          :integer          not null, primary key
#  key         :string(255)
#  value       :text
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site_setting do
    key "MyString"
    value "MyString"
    description "MyText"
  end
end
