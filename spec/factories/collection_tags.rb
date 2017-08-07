# == Schema Information
#
# Table name: collection_tags
#
#  id            :integer          not null, primary key
#  collection_id :integer
#  tag_id        :integer
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :collection_tag do
  end
end
