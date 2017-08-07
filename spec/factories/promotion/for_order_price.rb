FactoryGirl.define do
  factory :'promotion/for_order_price', class: Promotion::ForShippingFee do
    description 'promotion is a promotion'
    rule 'shipping_fee_discount'
    rule_parameters { { 'threshold_price_tier_id' => create(:price_tier).id } }
    sequence(:name) { |n| "No.#{n} order_price_promotion" }
    targets 'subtotal'
    begins_at 2.days.from_now
    ends_at 8.days.from_now
    after(:create) do |promotion|
      promotion.rules.create!(
        condition: 'threshold',
        threshold_id: create(:price_tier, :twd_499)
      )
    end
  end
end
