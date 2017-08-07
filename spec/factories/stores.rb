# == Schema Information
#
# Table name: stores
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  name                   :string(255)
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
#  title                  :string(255)
#  description            :text
#  avatar                 :string(255)
#  code                   :string(255)
#  slug                   :string(255)
#  tap_settings           :json
#  logo                   :string
#  store_footer_img       :string
#  contact_info           :hstore
#

FactoryGirl.define do
  factory :store do
    sequence(:name) { |n| "store#{n}" }
    sequence(:email) { |n| "store#{n}@commandp.com" }
    password 'ABcd1234'
    title 'Death Planet'
    description 'Join DarkSide'
  end
end
