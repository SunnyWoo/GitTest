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

require 'rails_helper'

RSpec.describe CouponRule, type: :model do
  it { should be_kind_of(ActsAsFavorRule) }

  context 'relations and validations' do
    it { should belong_to :coupon }
    it { should validate_inclusion_of(:condition).in_array(ActsAsFavorRule::CONDITIONS - %w(include_free_shipping_coupon)) }

    context 'quantity validation' do
      context 'when condition is threshold' do
        subject { CouponRule.new condition: 'threshold' }
        it { should_not validate_numericality_of(:quantity) }
      end
      context 'when condition is not threshold' do
        subject { CouponRule.new condition: 'include_product_models' }
        it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1).with_message(:invalid_coupon_rules_quantity) }
      end
    end
  end

  it { should delegate_method(:prices).to(:threshold).with_prefix(:threshold) }

  context '#to_react' do
    Given(:rule) { build(:coupon_rule, quantity: 12) }
    Given(:react_obj) { rule.to_react }
    Then { react_obj.keys == CouponRule::TO_REACT_ATTRIBUTES }
    CouponRule::TO_REACT_ATTRIBUTES.map(&:to_sym).each do |key|
      And { react_obj.send(:[], key) == rule.send(key) }
    end
  end

  context '#to_embedded_hash' do
    Given(:rule) { build(:coupon_rule, quantity: 12, threshold: build(:price_tier)) }
    Given(:obj) { rule.to_embedded_hash }
    attrs = CouponRule::TO_REACT_ATTRIBUTES + %w(threshold_prices)
    Then { obj.keys == attrs }
    attrs.each do |key|
      And { obj.send(:[], key) == rule.send(key) }
    end
  end

  context '#set_quantity' do
    context 'quantity would be 1 when coupon.condition is simple (rule condition should not be threshold)' do
      Given(:rule) { build(:coupon_rule, condition: 'include_product_models', quantity: 23, coupon: build(:coupon, condition: 'simple')) }
      When { rule.send :set_quantity }
      Then { rule.quantity == 1 }
    end

    context 'quantity would be nil when condition is threshold' do
      Given(:rule) { build(:coupon_rule, condition: 'threshold', quantity: 23, coupon: build(:coupon, condition: 'simple')) }
      When { rule.send :set_quantity }
      Then { rule.quantity.blank? }
    end
  end
end
