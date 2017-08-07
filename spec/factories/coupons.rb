# == Schema Information
#
# Table name: coupons
#
#  id                       :integer          not null, primary key
#  title                    :string(255)
#  code                     :string(255)
#  expired_at               :date
#  created_at               :datetime
#  updated_at               :datetime
#  price_tier_id            :integer
#  parent_id                :integer
#  children_count           :integer          default(0)
#  discount_type            :string(255)
#  percentage               :decimal(8, 2)
#  condition                :string(255)
#  threshold_id             :integer
#  product_model_ids        :integer          default([]), is an Array
#  apply_target             :string(255)
#  usage_count              :integer          default(0)
#  usage_count_limit        :integer          default(-1)
#  begin_at                 :date
#  is_enabled               :boolean          default(TRUE)
#  auto_approve             :boolean          default(FALSE)
#  designer_ids             :integer          default([]), is an Array
#  work_gids                :text             default([]), is an Array
#  user_usage_count_limit   :integer          default(-1)
#  base_price_type          :string(255)
#  apply_count_limit        :integer
#  product_category_ids     :integer          default([]), is an Array
#  bdevent_id               :integer
#  settings                 :hstore           default({})
#  is_free_shipping         :boolean          default(FALSE)
#  is_not_include_promotion :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :coupon do
    transient do
      # 可用 price_table: {'TWD' => 900} 建立對應的貨幣以及價格資料
      price_table('USD' => 5, 'TWD' => 150)
      threshold_price_table nil
    end

    discount_type 'fixed'
    condition 'none'
    title 'hello coupon'
    price_tier { build(:price_tier, prices: price_table) }
    threshold { build(:price_tier, prices: threshold_price_table) if threshold_price_table }
    usage_count_limit 1
    user_usage_count_limit 1
    base_price_type 'special'
    apply_count_limit 1

    factory :percentage_coupon do
      discount_type 'percentage'
      percentage 0.2
    end

    factory :used_coupon do
      after(:create) do |coupon|
        create(:order, coupon: coupon)
      end
    end

    factory :event_coupon do
      usage_count_limit -1
    end

    factory :max_price_coupon do
      usage_count_limit -1
      price_table('USD' => 9999, 'TWD' => 99999)
    end

    factory :rule_coupon do
      condition 'rules'
    end
  end
end
