# == Schema Information
#
# Table name: variants
#
#  id         :integer          not null, primary key
#  product_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :variant do
    product { create :product_model }
  end
end
