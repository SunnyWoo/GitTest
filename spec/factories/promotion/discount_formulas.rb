FactoryGirl.define do
  factory :discount_formula, class: Promotion::DiscountFormula do
    transient do
      price_table nil
    end

    transient do
      percentage { nil }
      discount_type { 'fixed' }
      price_tier_id { create(:price_tier, prices: price_table) if price_table }
    end

    # Usage:
    # formula = build(:discount_formula, :fixed, price_table: { 'TWD' => 99.0 })

    initialize_with {
      Promotion::DiscountFormula.new(
        'discount_type' => discount_type,
        'percentage' => percentage,
        'price_tier_id' => price_tier_id
      )
    }

    trait :fixed do
      discount_type 'fixed'
    end

    trait :percentage do
      discount_type 'percentage'
    end

    trait :pay do
      discount_type 'pay'
    end
  end
end
