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

require 'rails_helper'

RSpec.describe RoleGroup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
