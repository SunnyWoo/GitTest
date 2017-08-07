require 'spec_helper'

describe Pricing::CouponItemAdjustmentBuilder do
  Given!(:pricing_order) { order }
  Given(:order) { build(:order, coupon: coupon, currency: 'TWD') }
  Given(:builder) { Pricing::CouponItemAdjustmentBuilder.new(order) }
  Given(:coupon) { create :coupon, apply_count_limit: apply_count_limit }
  Given(:discount_formula) { build :discount_formula, :fixed, price_table: { 'TWD' => 200.0 } }
  Given(:apply_count_limit) { 5 }

  Given {
    create_basic_currencies
    coupon.stub(:discount_formula).and_return(discount_formula)
  }

  Given(:threshold_rule) { create(:threshold_rule, threshold: create(:price_tier)) }
  Given(:product_model_rule) { create(:product_model_rule, product_model_ids: [1, 2, 3]) }
  Given(:bdevent_rule) { create(:bdevent_rule, bdevent_id: 1) }
  Given(:product_category_rule){ create(:product_category_rule, product_category_ids: [1, 2, 3]) }

  describe '#group_conformed_items' do
    Given(:ipad_air2_work) { create :work, :with_ipad_air2_model }
    Given(:mug_work) { create :work, :with_mug_model }

    Given(:iphone6_item) { create :iphone6_order_item, order: order, quantity: 10 }
    Given(:ipad_air2_item) { create :order_item, order: order, quantity: 10, itemable: ipad_air2_work }
    Given(:mug_item) { create :order_item, order: order, quantity: 10, itemable: mug_work }
    Given!(:items) { [iphone6_item, ipad_air2_item, mug_item] }

    Given(:rule1) { Promotion::Rule::IncludeProductModels.new([mug_work.product], 3) }
    Given(:rule2) { Promotion::Rule::IncludeProductModels.new([ipad_air2_work.product], 1) }
    Given(:rules) { [rule1, rule2] }

    Given {
      allow(builder).to receive(:grouping_rules).and_return(rules)
      order.order_items = items
    }

    When(:groups) { builder.group_conformed_items }
    Then { expect(groups.size).to eq 3 }
    And { expect(groups[0]).to be_kind_of(Pricing::DiscountGroup) }
    And { expect(groups[0].size).to eq 4 }
    And { expect(groups[0].map(&:item)).to match_array([mug_item, mug_item, mug_item, ipad_air2_item]) }
    And { expect(groups[1]).to be_kind_of(Pricing::DiscountGroup) }
    And { expect(groups[1].size).to eq 4 }
    And { expect(groups[1].map(&:item)).to match_array([mug_item, mug_item, mug_item, ipad_air2_item]) }
    And { expect(groups[2]).to be_kind_of(Pricing::DiscountGroup) }
    And { expect(groups[2].size).to eq 4 }
    And { expect(groups[2].map(&:item)).to match_array([mug_item, mug_item, mug_item, ipad_air2_item]) }
  end

  describe '#merge_discount_info_by_item' do
    Given(:item1) { build(:order_item, quantity: 10).tap { |oi| pricing_order.order_items << oi } }
    Given(:item2) { build(:order_item, quantity: 5).tap { |oi| pricing_order.order_items << oi } }

    Given(:discount1) { { price: Price.new(66), quantity: 3 } }
    Given(:discount2) { { price: Price.new(34), quantity: 1 } }

    Given(:group1) { double(Pricing::DiscountGroup, discount_info_by_item: { item1 => discount1.dup, item2 => discount2.dup }) }
    Given(:group2) { double(Pricing::DiscountGroup, discount_info_by_item: { item1 => discount1.dup, item2 => discount2.dup }) }
    Given(:group3) { double(Pricing::DiscountGroup, discount_info_by_item: { item1 => discount1.dup, item2 => discount2.dup }) }
    Given(:groups) { [group1, group2, group3] }
    When(:ans) { builder.merge_discount_info_by_item(groups) }

    Then { expect(ans.size).to eq 2 }
    And { expect(ans[item1]).to eq(quantity: 9, price: Price.new(198)) }
    And { expect(ans[item2]).to eq(quantity: 3, price: Price.new(102)) }
  end
end
