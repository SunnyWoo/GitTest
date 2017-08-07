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

# NOTE: not used in v3 api, remove me later
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :first_name, :last_name, :mobile,
             :mobile_country_code, :avatar, :birthday

  def avatar
    {
      'use_default_image' => object.avatar.blank?,
      'thumb' => object.avatar.url, # FIXME: it should be a thumbnail url
      'normal' => object.avatar.url
    }
  end

  def username
    object.display_name
  end

  def mobile
    object.is_a?(User) ? object.mobile : nil
  end

  def first_name
    object.is_a?(User) ? object.first_name : nil
  end

  def last_name
    object.is_a?(User) ? object.last_name : nil
  end

  def mobile_country_code
    object.is_a?(User) ? object.mobile_country_code : nil
  end

  def birthday
    object.is_a?(User) ? object.birthday : nil
  end
end
