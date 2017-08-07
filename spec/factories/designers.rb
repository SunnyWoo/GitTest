# == Schema Information
#
# Table name: designers
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
#  display_name           :string(255)
#  avatar                 :string(255)
#  description            :text
#  image_meta             :json
#  created_at             :datetime
#  updated_at             :datetime
#  code                   :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :designer do
    sequence(:username) { |n| "designer#{n}" }
    sequence(:email) { |n| "designer#{n}@commandp.me" }
    password 'password'
    password_confirmation 'password'

    trait :with_avatar do
      avatar { fixture_file_upload('spec/photos/test.jpg', 'image/jpeg') }
    end
  end
end
