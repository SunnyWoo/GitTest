# == Schema Information
#
# Table name: collection_works
#
#  id            :integer          not null, primary key
#  collection_id :integer
#  work_id       :integer
#  created_at    :datetime
#  updated_at    :datetime
#  work_type     :string(255)
#  position      :integer
#

FactoryGirl.define do
  factory :collection_work do
    collection_id 1
    standardized_work_id 1
  end
end
