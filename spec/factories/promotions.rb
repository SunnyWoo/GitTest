# == Schema Information
#
# Table name: promotions
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :text
#  type            :string(255)      not null
#  aasm_state      :integer
#  rule            :integer
#  rule_parameters :json
#  targets         :integer
#  begins_at       :datetime
#  ends_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  level           :integer
#

FactoryGirl.define do
  factory :promotion do
    description 'promotion is a promotion'
    rule 'simple_discount'
    begins_at { Time.zone.now.days_since(3) }
    ends_at { Time.zone.now.months_since(3) }
    rule_parameters { { 'discount_type' => 'fixed', 'price_tier_id' => create(:price_tier).id } }
    targets 'special'
    factory :standardized_work_promotion, class: Promotion::ForItemablePrice do
      sequence(:name) { |n| "No.#{n} standardized_work_promotion" }
    end

    factory :promotion_for_product_category, class: Promotion::ForProductCategory do
      sequence(:name) { |n| "No.#{n} product_category_promotion" }
    end

    factory :product_model_promotion, class: Promotion::ForItemablePrice do
      sequence(:name) { |n| "No.#{n} product_model_promotion" }
    end

    factory :promotion_for_itemable_price, class: Promotion::ForItemablePrice do
      sequence(:name) { |n| "No.#{n} product_for_itemable_price" }
    end

    factory :promotion_for_shipping_fee, class: Promotion::ForShippingFee do
      sequence(:name) { |n| "No.#{n} promotion_for_shipping_fee" }
      after(:create) do |promotion|
        promotion.rules.create!(
          condition: 'threshold',
          threshold: create(:price_tier, :twd_499)
        )
      end
    end

    factory :promotion_for_product_model, class: Promotion::ForProductModel do
      sequence(:name) { |n| "No.#{n} promotion_for_product_model" }
    end

    factory :promotion_for_order_price, class: Promotion::ForOrderPrice do
      sequence(:name) { |n| "No.#{n} promotion_for_order_price" }
      after(:create) do |promotion|
        promotion.rules.create!(
            condition: 'threshold',
            threshold: create(:price_tier, :twd_100)
        )
      end
    end

    factory :promotion_for_free_shipping_coupon, class: Promotion::ForShippingFee do
      sequence(:name) { |n| "No.#{n} promotion_for_free_shipping_coupon" }
      after(:create) do |promotion|
        promotion.rules.create!(
            condition: 'include_free_shipping_coupon'
        )
      end
    end

    factory :promotion_for_shipping_fee_pured, class: Promotion::ForShippingFee do
      sequence(:name) { |n| "No.#{n} promotion_for_shipping_fee" }
    end

    factory :order_price_promotion, class: Promotion::ForShippingFee do
      sequence(:name) { |n| "No.#{n} order_price_promotion" }
      rule 'shipping_fee_discount'
      targets 'subtotal'
    end

    trait :fixed do
      rule_parameters { { 'discount_type' => 'fixed', 'price_tier_id' => create(:price_tier).id } }
    end

    trait :percentage do
      rule_parameters { { 'discount_type' => 'percentage', 'percentage' => 0.8 } }
    end

    trait :pay do
      rule_parameters { { 'discount_type' => 'pay', 'price_tier_id' => create(:price_tier).id } }
    end
  end
end
