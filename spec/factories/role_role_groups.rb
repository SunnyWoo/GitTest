# == Schema Information
#
# Table name: role_role_groups
#
#  id            :integer          not null, primary key
#  role_id       :integer
#  role_group_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :role_role_group do
  end
end
