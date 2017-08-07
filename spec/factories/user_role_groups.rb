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

FactoryGirl.define do
  factory :user_role_group do
  end
end
