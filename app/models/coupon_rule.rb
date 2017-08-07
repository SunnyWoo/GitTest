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

class CouponRule < ActiveRecord::Base
  include ActsAsFavorRule

  TO_REACT_ATTRIBUTES = %w(id quantity condition threshold_id product_model_ids
                           designer_ids product_category_ids work_gids bdevent_id).freeze

  belongs_to :coupon

  validates :condition, inclusion: ActsAsFavorRule::CONDITIONS - %w(include_free_shipping_coupon)
  validates_numericality_of :quantity, greater_than_or_equal_to: 1, unless: :threshold?, message: :invalid_coupon_rules_quantity

  before_create :set_quantity

  delegate :prices, to: :threshold, prefix: :threshold, allow_nil: true

  def to_react
    TO_REACT_ATTRIBUTES.each_with_object({}) do |key, hash|
      hash[key] = send(key)
    end.with_indifferent_access
  end

  def to_embedded_hash
    to_react.merge threshold_prices: threshold_prices
  end

  private

  def set_quantity
    self.quantity = 1 if coupon.try(:condition) == 'simple'
    self.quantity = nil if condition == 'threshold'
  end
end
