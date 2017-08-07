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

require 'spec_helper'

describe UserSerializer do
  it 'works' do
    user = create(:user)
    json = JSON.parse(UserSerializer.new(user).to_json)
    expect(json).to eq(
      'user' => {
        'id' => user.id,
        'email' => user.email,
        'mobile_country_code' => user.mobile_country_code,
        'mobile' => user.mobile,
        'username' => user.username,
        'first_name' => user.first_name,
        'last_name' => user.last_name,
        'birthday' => user.birthday,
        'avatar' => {
          'use_default_image' => true,
          'thumb' => user.avatar.url,
          'normal' => user.avatar.url
        }
      }
    )
  end
end
