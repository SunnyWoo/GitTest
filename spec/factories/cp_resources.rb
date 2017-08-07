# == Schema Information
#
# Table name: cp_resources
#
#  id            :integer          not null, primary key
#  version       :integer
#  aasm_state    :string
#  publish_at    :datetime
#  list_urls     :json
#  small_package :string
#  large_package :string
#  memo          :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
  factory :cp_resource do
    version 1
  end
end
