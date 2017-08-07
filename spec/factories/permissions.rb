# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  role_id    :integer
#  action     :string(255)
#  resource   :string(255)
#  created_at :datetime
#  updated_at :datetime
#
FactoryGirl.define do
  factory :permission do
  end
end
