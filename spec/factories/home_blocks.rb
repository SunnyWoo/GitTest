# == Schema Information
#
# Table name: home_blocks
#
#  id         :integer          not null, primary key
#  template   :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :home_block do
    sequence(:title) { |n| "Block #{n}" }
    template 'collection_2'
    position 1
  end
end
