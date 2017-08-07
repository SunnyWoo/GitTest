# require 'spec_helper'

# describe Promotion::SimpleDiscountStrategy do
#   Given(:promotion) { create :'promotion/for_standardized_work' }

#   context 'for persisted order' do
#     Given(:order) { create :order, :with_standardized_work }
#     Given { create :promotion_reference, promotion: promotion, promotable: order.order_items.first.itemable }
#     context '#apply' do
#       Given(:effective_item) { order.order_items.first }
#       Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#       Then do
#         expect { strategy.apply(order) }.to change { effective_item.adjustments.count }.by(1)
#       end
#       And { effective_item.adjustments(true).map(&:value).sum != 0 }
#       And { effective_item.adjustments.last.apply? }
#     end

#     context '#fallback' do
#       Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#       context 'does not create fallback adjustment without corresponding apply adjustment' do
#         Given!(:adjustments_count) { order.order_items.first.adjustments.count }
#         When { strategy.fallback(order) }
#         Then { order.reload.order_items.first.adjustments.size == adjustments_count }
#       end

#       context 'does create fallback adjustment with corresponding apply adjustment' do
#         Given(:effective_item) { order.order_items.first }
#         Given { effective_item.adjustments.create! order: order, event: 'apply', source: promotion, target: 'special', value: promotion.price_in_currency(order.currency) }
#         When { strategy.fallback(order) }
#         Then { effective_item.adjustments(true).map(&:value).sum == 0 }
#         And { effective_item.adjustments.first.fallback? }

#         context 'does create right fallback with corresponding apply with more than one promotion adjustments' do
#           Given(:price_tier) { create :price_tier, tier: 2, prices: { "USD" => 20, "TWD" => 600 } }
#           Given(:promotion2) { create :'promotion/for_standardized_work', rule_parameters: { 'discount_type' => 'fixed', 'price_tier_id' => price_tier.id } }
#           Given(:strategy2) { Promotion::SimpleDiscountStrategy.new promotion2 }
#           Given { create :promotion_reference, promotion: promotion2, promotable: order.order_items.first.itemable }
#           before { order.order_items.first.adjustments.create order: order, event: 'apply', source: promotion2, target: 'special', value: promotion2.price_in_currency(order.currency) }
#           When { strategy2.fallback(order) }
#           Then { order.order_items.first.adjustments(true).map(&:value).sum == 0 }
#           And { order.order_items.first.adjustments.order(:id).first.fallback? }
#         end
#       end
#     end

#     context '#calculate_adjustment_value' do
#       Given(:item) { order.order_items.first }
#       Given(:price_tier) { create :price_tier }
#       Given(:hyper_price_tier) { create :price_tier, tier: 2, prices: { "USD" => 999, "TWD" => 999_999 } }
#       context 'with discount_type fixed' do
#         context 'when fixed_price is less than item.price' do
#           Given(:promotion) { create :'promotion/for_standardized_work' }
#           Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#           When(:discount_value) { strategy.calculate_adjustment_value(order, item) }
#           Then { discount_value == - promotion.price_in_currency(item.order.currency) }
#         end

#         context 'when fixed_price is more than item.price' do
#           Given(:promotion) { create :'promotion/for_standardized_work', rule_parameters: { 'discount_type' => 'fixed', 'price_tier_id' => hyper_price_tier.id } }
#           Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#           When(:discount_value) { strategy.calculate_adjustment_value(order, item) }
#           Then { discount_value == - item.price_in_currency(item.order.currency) }
#         end
#       end

#       context 'with discount_type percentage' do
#         Given(:promotion) { create :'promotion/for_standardized_work', rule_parameters: { 'discount_type' => 'percentage', percentage: 0.8 } }
#         Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#         When(:discount_value) { strategy.calculate_adjustment_value(order, item) }
#         Then { discount_value == -(item.price_in_currency(item.order.currency) * 0.2).round(2) }
#       end

#       context 'with discount_type pay' do
#         Given(:promotion) { create :'promotion/for_standardized_work', rule_parameters: { 'discount_type' => 'pay', 'price_tier_id' => price_tier.id } }
#         Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#         When(:discount_value) { strategy.calculate_adjustment_value(order, item) }
#         Then { discount_value == (promotion.price_in_currency(item.order.currency) - item.price_in_currency(item.order.currency)) }
#       end
#     end
#   end

#   context 'for non-persisted order' do
#     describe '#build_apply_adjustment' do
#       Given(:order) { build(:order) }
#       Given(:order_item) { build(:order_item, :with_standardized_work, order: order) }
#       Given(:new_adjustment) { order.adjustments[0] }
#       When { promotion.build_apply_adjustment(order, order_item) }
#       Then { expect(order.adjustments.size).to eq 1 }
#       And { expect(order_item.adjustments.size).to eq 1 }
#       And { expect(new_adjustment).to be_new_record }

#       context 'even called twice' do
#         When { promotion.build_apply_adjustment(order, order_item) }
#         Then { expect(order.adjustments.size).to eq 1 }
#         And { expect(order_item.adjustments.size).to eq 1 }
#       end
#     end
#   end

#   describe '#calculate_adjusted_price' do
#     Given(:base_price) { Price.new('TWD' => 1999.0) }

#     context 'with discount_type fixed' do
#       context 'when fixed_price is less than base_price' do
#         Given(:promotion) { create :'promotion/for_standardized_work' }
#         Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#         When(:adjusted_price) { strategy.calculate_adjusted_price(base_price) }
#         Then { expect(adjusted_price.value).to eq 1699.0 }
#       end

#       context 'when fixed_price is more than base_price' do
#         Given(:base_price) { Price.new('TWD' => 299.0) }
#         Given(:promotion) { create :'promotion/for_standardized_work' }
#         Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#         When(:adjusted_price) { strategy.calculate_adjusted_price(base_price) }
#         Then { expect(adjusted_price.value).to eq 0 }
#       end
#     end

#     context 'with discount_type percentage' do
#       Given(:promotion) { create :'promotion/for_standardized_work', rule_parameters: { 'discount_type' => 'percentage', percentage: 0.8 } }
#       Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#       When(:adjusted_price) { strategy.calculate_adjusted_price(base_price) }
#       Then { expect(adjusted_price.value).to eq 1599.2 }
#     end

#     context 'with discount_type pay' do
#       Given(:price_tier) { create :price_tier, tier: 2, prices: { "USD" => 20, "TWD" => 600 } }
#       Given(:promotion) { create :'promotion/for_standardized_work', rule_parameters: { 'discount_type' => 'pay', 'price_tier_id' => price_tier.id } }
#       Given(:strategy) { Promotion::SimpleDiscountStrategy.new promotion }
#       When(:adjusted_price) { strategy.calculate_adjusted_price(base_price) }
#       Then { expect(adjusted_price.value).to eq 600.0 }
#     end
#   end
# end
