FactoryGirl.define do
  factory :'promotion/for_standardized_work', class: Promotion::ForItemablePrice do
    description 'promotion is a promotion'
    rule 'simple_discount'
    rule_parameters { { 'discount_type' => 'fixed', 'price_tier_id' => create(:price_tier).id } }
    sequence(:name) { |n| "No.#{n} standardiezd_work_promotion" }
    targets 'special'
    begins_at 2.days.from_now
    ends_at 8.days.from_now
  end
end
