# == Schema Information
#
# Table name: recommend_sorts
#
#  id              :integer          not null, primary key
#  design_platform :string(255)
#  sort            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :recommend_sort do
    design_platform 'website'
    sort 'new'
  end
end
