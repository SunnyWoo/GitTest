# == Schema Information
#
# Table name: option_value_variants
#
#  id              :integer          not null, primary key
#  variant_id      :integer
#  option_value_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
  factory :option_value_variant do
    variant { create :variant }
    option_value { create :option_value }
  end
end
