# == Schema Information
#
# Table name: omniauths
#
#  id               :integer          not null, primary key
#  provider         :string(255)
#  uid              :string(255)
#  oauth_token      :text
#  oauth_expires_at :datetime
#  owner_id         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  email            :string(255)
#  username         :string(255)
#  owner_type       :string(255)
#  oauth_secret     :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :omniauth do
    provider "facebook"
    sequence(:uid) { |n| "uid-#{n}" }
    sequence(:oauth_token) { |n| "oauth-#{n}" }
    sequence(:email) { |n| "user#{n}@mail.com" }
    owner { create :user }

    factory :dropbox_omniauth do
      provider 'dropbox'
      oauth_token { SecureRandom.hex }
      oauth_secret { SecureRandom.hex }
    end
  end
end
