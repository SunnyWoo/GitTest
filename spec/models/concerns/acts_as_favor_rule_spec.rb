require 'rails_helper'

Temping.create :dummy_coupon_rule do
  with_columns do |t|
    t.integer :quantity
    t.integer :threshold_id
    t.integer :bdevent_id

    t.string :condition
    t.integer :designer_ids, default: [], array: true
    t.integer :product_model_ids, default: [], array: true
    t.integer :product_category_ids, default: [], array: true
    t.text :work_gids, default: [], array: true
  end
  include ActsAsFavorRule
end

describe ActsAsFavorRule do
  context '#validations and relations' do
    Given(:attrs) do
      {
        condition: 'threshold',
        threshold: build(:price_tier),
        bdevent: build(:bdevent),
      }
    end
    Given(:dummy) { DummyCouponRule.new(attrs) }
    subject { dummy }
    # relations
    Then { expect(dummy).to belong_to :threshold }
    And { expect(dummy).to belong_to :bdevent }
    # validations
    And { expect(dummy).to validate_inclusion_of(:condition).in_array(ActsAsFavorRule::CONDITIONS) }

    it_behaves_like 'validate presence if', :threshold_id, :threshold?, :invalid_threshold_coupon
    it_behaves_like 'validate presence if', :designer_ids, :check_designers?, :invalid_designer_ids
    it_behaves_like 'validate presence if', :product_model_ids, :check_product_models?, :invalid_product_model_ids
    it_behaves_like 'validate presence if', :work_gids, :include_works?, :invalid_work_gids
    it_behaves_like 'validate presence if', :product_category_ids, :include_product_categories?, :invalid_product_category_ids
    it_behaves_like 'validate presence if', :bdevent_id, :include_bdevent?
  end

  context '#level, #item_level?, #order_level?' do
    Given(:dummy) { DummyCouponRule.new }

    order_conditions = %w(threshold)
    item_conditions = ActsAsFavorRule::CONDITIONS - order_conditions
    order_conditions.each do |condition|
      context "when condition is #{condition}" do
        When { dummy.condition = condition }
        Then { dummy.level == 'order' }
        And { dummy.item_level? == false }
        And { dummy.order_level? == true }
      end
    end

    item_conditions.each do |condition|
      context "when condition is #{condition}" do
        When { dummy.condition = condition }
        Then { dummy.level == 'item' }
        And { dummy.item_level? == true }
        And { dummy.order_level? == false }
      end
    end
  end

  context '#strategy' do
    context 'threshold' do
      Given(:dummy) { DummyCouponRule.new condition: 'threshold', threshold: build(:price_tier) }
      Then { dummy.strategy.is_a? Promotion::Rule::Threshold }
    end
    context 'include_product_models' do
      Given!(:product_model) { create(:product_model) }
      Given(:dummy) { DummyCouponRule.new condition: 'include_product_models', product_model_ids: [product_model.id], quantity: 1 }
      Then { dummy.strategy.is_a? Promotion::Rule::IncludeProductModels }
    end
    context 'include_product_categories' do
      Given!(:product_category) { create(:product_category) }
      Given(:dummy) { DummyCouponRule.new condition: 'include_product_categories', product_category_ids: [product_category.id], quantity: 1 }
      Then { dummy.strategy.is_a? Promotion::Rule::IncludeProductCategories }
    end
    context 'include_designers' do
      Given!(:designer) { create(:designer) }
      Given(:dummy) { DummyCouponRule.new condition: 'include_designers', designer_ids: [designer.id], quantity: 1 }
      Then { dummy.strategy.is_a? Promotion::Rule::IncludeDesigners }
    end
    context 'include_works' do
      Given!(:work) { create(:work) }
      Given(:dummy) { DummyCouponRule.new condition: 'include_works', work_gids: [work.to_global_id], quantity: 1 }
      Then { dummy.strategy.is_a? Promotion::Rule::IncludeWorks }
    end
    context 'include_designers_models' do
      Given!(:product_model) { create(:product_model) }
      Given!(:designer) { create(:designer) }
      Given(:dummy) { DummyCouponRule.new condition: 'include_designers_models', product_model_ids: [product_model.id], designer_ids: [designer.id], quantity: 1 }
      Then { dummy.strategy.is_a? Promotion::Rule::IncludeDesignerModels }
    end
    context 'include_bdevent' do
      Given(:dummy) { DummyCouponRule.new condition: 'include_bdevent', bdevent_id: 1 }
      Then { dummy.strategy.is_a? Promotion::Rule::IncludeBdevent }
    end
    context 'include_free_shipping_coupon' do
      Given(:dummy) { DummyCouponRule.new condition: 'include_free_shipping_coupon' }
      Then { dummy.strategy.is_a? Promotion::Rule::IncludeFreeShippingCoupon }
    end
    context 'otherwise: raise error' do
      Given(:dummy) { DummyCouponRule.new condition: 'nothing_but_error' }
      Then { expect { dummy.strategy }.to raise_error(NotImplementedError) }
    end
  end
end
