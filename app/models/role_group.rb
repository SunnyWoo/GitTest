# == Schema Information
#
# Table name: role_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class RoleGroup < ActiveRecord::Base
  has_paper_trail
  include Logcraft::Trackable

  has_many :user_role_groups
  has_many :user, through: :user_role_groups
  has_many :role_role_groups
  has_many :roles, through: :role_role_groups

  def role_names
    roles.pluck :name
  end
end
