# == Schema Information
#
# Table name: store_components
#
#  id         :integer          not null, primary key
#  store_id   :integer
#  key        :string(255)
#  image      :string(255)
#  position   :integer
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :store_component do
  end
end
