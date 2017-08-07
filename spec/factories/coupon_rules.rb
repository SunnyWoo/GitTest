# == Schema Information
#
# Table name: coupon_rules
#
#  id                   :integer          not null, primary key
#  coupon_id            :integer
#  condition            :string(255)
#  threshold_id         :integer
#  product_model_ids    :integer          default([]), is an Array
#  designer_ids         :integer          default([]), is an Array
#  product_category_ids :integer          default([]), is an Array
#  work_gids            :text             default([]), is an Array
#  quantity             :integer
#  created_at           :datetime
#  updated_at           :datetime
#  bdevent_id           :integer
#

FactoryGirl.define do
  factory :coupon_rule do
    transient do
      threshold_price_table nil
    end

    condition 'threshold'
    threshold { create(:price_tier, prices: threshold_price_table) if threshold_price_table }
    quantity 1

    factory :threshold_rule do
      condition 'threshold'
      threshold { create(:price_tier, prices: threshold_price_table) if threshold_price_table }
    end

    factory :product_model_rule do
      condition 'include_product_models'
    end

    factory :product_category_rule do
      condition 'include_product_categories'
    end

    factory :designer_rule do
      condition 'include_designers'
    end

    factory :designer_model_rule do
      condition 'include_designers_models'
    end

    factory :work_rule do
      condition 'include_works'
    end

    factory :bdevent_rule do
      condition 'include_bdevent'
    end
  end
end
