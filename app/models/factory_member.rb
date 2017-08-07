# == Schema Information
#
# Table name: factory_members
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
#  created_at             :datetime
#  updated_at             :datetime
#  factory_id             :integer
#  enabled                :boolean          default(TRUE)
#

class FactoryMember < ActiveRecord::Base
  has_paper_trail only: %i(username email enabled encrypted_password)
  include Logcraft::Trackable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :notes, as: :user
  has_many :user_role_groups, as: :user
  has_many :role_groups, through: :user_role_groups, class_name: 'FactoryRoleGroup'
  has_many :roles, through: :role_groups
  has_many :permissions, through: :roles
  belongs_to :factory

  attr_writer :login

  validates :username, :factory_id, presence: true
  validates :username, uniqueness: true

  def login
    @login || username || email
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    email = conditions.delete(:email)
    if email.present?
      where(conditions).find_by(['lower(username) = :value OR lower(email) = :value', { value: email.downcase }])
    else
      find_by(conditions)
    end
  end

  def active_for_authentication?
    super && self.enabled?
  end
end
