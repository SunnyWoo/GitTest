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

class AuthToken < ActiveRecord::Base
  belongs_to :user
  validates :token, uniqueness: true
  validates :user_id, presence: true

  before_validation :generate_token

  def generate_token
    return if token.present? && !AuthToken.exists?(token: token)
    self.token = UUIDTools::UUID.timestamp_create.to_s.delete('-')
  end

  def self.authenticate(token)
    AuthToken.find_by!(token: token).user
  end
end
