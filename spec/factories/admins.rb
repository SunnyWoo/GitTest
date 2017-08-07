# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
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
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#

FactoryGirl.define do
  factory :admin do
    sequence(:email) { |n| "admin#{n}@commandp.me" }
    password '12341234Gg'
    password_confirmation '12341234Gg'
  end
end
