# == Schema Information
#
# Table name: user_role_groups
#
#  id            :integer          not null, primary key
#  role_group_id :integer
#  user_id       :integer
#  user_type     :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

RSpec.describe UserRoleGroup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
