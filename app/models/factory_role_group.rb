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

class FactoryRoleGroup < RoleGroup
end
