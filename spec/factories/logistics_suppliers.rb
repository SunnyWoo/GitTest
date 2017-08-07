# == Schema Information
#
# Table name: logistics_suppliers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  position   :integer
#

FactoryGirl.define do
  factory :logistics_supplier do
  end
end
