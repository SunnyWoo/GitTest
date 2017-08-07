# == Schema Information
#
# Table name: change_price_events
#
#  id            :integer          not null, primary key
#  operator_id   :integer
#  target_ids    :integer          default([]), is an Array
#  price_tier_id :integer
#  target_type   :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  aasm_state    :string(255)
#

FactoryGirl.define do
  factory :change_price_event do
    operator_id { create(:admin).id }
    price_tier_id { create(:price_tier).id }

    trait :with_standardized_work_price do
      target_type 'StandardizedWorkPrice'
    end

    trait :with_product_price do
      target_type 'ProductPrice'
    end

    trait :with_product_customized_price do
      target_type 'ProductCustomizedPrice'
    end
  end
end
