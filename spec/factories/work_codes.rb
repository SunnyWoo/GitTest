# == Schema Information
#
# Table name: work_codes
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  user_type    :string(255)
#  work_type    :string(255)
#  work_id      :integer
#  code         :string(255)
#  product_code :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

FactoryGirl.define do
  factory :work_code do
    user_id 1
    user_type 'Designer'
    work { create :work }
    sequence(:code) { |n| "code#{n}" }
  end
end
