# == Schema Information
#
# Table name: export_orders
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :export_order do
  end
end
