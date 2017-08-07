# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  avatar                 :string(255)
#  role                   :integer
#  profile                :hstore
#  gender                 :integer
#  background             :string(255)
#  image_meta             :json
#  mobile                 :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  mobile_country_code    :string(16)
#

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@commandp.me" }
    password 'password'
    password_confirmation 'password'
    name 'User Name'
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    birthday '2000-10-10'
    confirmed_at Time.zone.now
    trait :with_designer_role do
      role 'designer'
    end

    trait :with_facebook do
      after(:create) do |user|
        create(:omniauth, owner: user)
      end
    end

    trait :without_confirmed do
      confirmed_at nil
      after(:create) do |user|
        user.confirmation_token = nil
        user.confirmation_sent_at = nil
        user.save
      end
    end

    factory :designer_user do
      with_designer_role
    end

    after(:create, &:generate_token)
  end
end
