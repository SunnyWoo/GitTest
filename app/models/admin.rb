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

class Admin < ActiveRecord::Base
  include Logcraft::Trackable
  include ActsAsAdjustmentSource

  has_many :notes, as: :user
  has_many :change_price_events, foreign_key: 'operator_id'

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable

  validates :password, format: { with:      /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/,
                                 message:   'Password should be composed of [A-Z], [a-z], and [0-9]',
                                 multiline: true
                               }

  def gravatar_url
    hash = Digest::MD5.hexdigest(email.downcase)
    "http://www.gravatar.com/avatar/#{hash}?s=40"
  end

  def source_name
    "#{self.class.name}: #{email.split('@')[0]}"
  end

  def account_name
    email[/^([A-z0-9._%+-]+)@[A-z0-9.-]+\.[A-z]{2,}$/, 1]
  end

  def self.current_admin
    Thread.current[:admin]
  end

  def self.current_admin=(admin)
    Thread.current[:admin] = admin
  end
end
