# == Schema Information
#
# Table name: factory_members
#
#  id                     :integer          not null, primary key
#  username               :string(255)      default(""), not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  factory_id             :integer
#  enabled                :boolean          default(TRUE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :factory_member do
    sequence(:username) { |n| "commandp#{n}" }
    sequence(:email) { |n| "commandp#{n}@commandp.me" }
    password '12341234'
    password_confirmation '12341234'

    factory_id { create(:factory).id }
  end
end
