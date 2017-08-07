# == Schema Information
#
# Table name: header_link_tags
#
#  id             :integer          not null, primary key
#  header_link_id :integer
#  style          :string(255)
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :header_link_tag do
    style 'primary'
    position 1
  end
end
