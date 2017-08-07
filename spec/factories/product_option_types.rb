# == Schema Information
#
# Table name: product_option_types
#
#  id             :integer          not null, primary key
#  product_id     :integer
#  option_type_id :integer
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :product_option_type do
    product { create(:product_model) }
    option_type { create(:option_type) }
  end
end
