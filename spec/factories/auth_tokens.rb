# == Schema Information
#
# Table name: auth_tokens
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  token      :string(255)
#  extra_info :json
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :auth_token do
    user { create(:user) }
    token SecureRandom.hex
  end
end
