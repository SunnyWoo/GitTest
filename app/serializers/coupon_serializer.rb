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

# NOTE: not used in v3 api, remove me later
class CouponSerializer < ActiveModel::Serializer
  attributes :title, :expired_at, :currencies, :is_used?

  def currencies
    if object.price_tier
      price_tier_array
    else
      currencies_array
    end
  end

  def price_tier_array
    object.price_tier.prices.map do |code, price|
      { code: code, price: price }
    end
  end

  def currencies_array
    object.currencies.map do |currency|
      { code: currency.code, price: currency.price }
    end
  end
end
