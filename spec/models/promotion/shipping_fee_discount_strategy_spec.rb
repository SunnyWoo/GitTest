# require 'spec_helper'

# describe Promotion::ShippingFeeDiscountStrategy do
#   before { create :site_setting, key: 'ShippingFeeSwitch', value: 'true' }
#   Given(:promotion) { create :'promotion/for_order_price' }

#   context 'for persisted order' do
#     Given(:order) { create :shipping_to_tw_order }
#     context '#apply' do
#       Given(:strategy) { Promotion::ShippingFeeDiscountStrategy.new promotion }
#       Given { strategy.apply(order) }
#       Then { order.reload.shipping_fee_discount != 0 }
#       And { order.reload.shipping_fee == order.reload.shipping_fee_discount }
#     end

#     context '#fallback' do
#       Given(:strategy) { Promotion::ShippingFeeDiscountStrategy.new promotion }
#       context 'does not create fallback adjustment without corresponding apply adjustment' do
#         Given!(:adjustments_count) { order.order_adjustments.count }
#         When { strategy.fallback(order) }
#         Then { order.reload.order_adjustments.size == adjustments_count }
#       end

#       context 'does create fallback adjustment with corresponding apply adjustment' do
#         Given { order.order_adjustments.create! order: order, event: 'apply', source: promotion, target: 'subtotal', value: promotion.threshold_price_in_currency(order.currency) }
#         When { strategy.fallback(order) }
#         Then { order.order_adjustments(true).map(&:value).sum == 0 }
#         And { order.order_adjustments.order(:id).last.fallback? }

#         context 'does create right fallback with corresponding apply with more than one promotion adjustments' do
#           Given(:price_tier) { create :price_tier, tier: 2, prices: { "USD" => 20, "TWD" => 600 } }
#           Given(:promotion2) { create :'promotion/for_order_price', rule_parameters: { 'threshold_price_tier_id' => price_tier.id } }
#           Given(:strategy2) { Promotion::ShippingFeeDiscountStrategy.new promotion2 }
#           before { order.order_adjustments.create order: order, event: 'apply', source: promotion2, target: 'subtotal', value: promotion2.threshold_price_in_currency(order.currency) }
#           When { strategy2.fallback(order) }
#           Then { order.order_adjustments(true).map(&:value).sum == 0 }
#           And { order.order_adjustments.order(:id).first.apply? }
#         end
#       end
#     end
#   end

#   describe 'for non-persisted order' do
#     Given!(:shipping_info) { create(:shipping_info, country_code: 'TW') }
#     Given(:order) { build(:order, order_items: [create(:order_item, :with_standardized_work)]) }
#     Given { order.shipping_info = shipping_info }
#     context 'when threshold_price is less than order price ' do
#       Given(:price_tier) { create :price_tier, tier: 2, prices: { "USD" => 2, "TWD" => 60 } }
#       Given(:promotion) { create :'promotion/for_order_price', rule_parameters: { 'threshold_price_tier_id' => price_tier.id } }
#       Given { promotion.update_columns(begins_at: Time.zone.now - 1.day, aasm_state: 2) }
#       Given { order.send(:calculate_price) }
#       Then { order.order_adjustments.size == 1 }
#       And { order.shipping_fee == order.shipping_fee_discount }

#       context 'even called twice' do
#         When { promotion.build_apply_adjustment(order) }
#         Then { order.order_adjustments.size == 1 }
#       end
#     end

#     context 'when threshold_price is more than order price ' do
#       Given(:price_tier) { create :price_tier, tier: 2, prices: { "USD" => 200, "TWD" => 6000 } }
#       Given(:promotion) { create :'promotion/for_order_price', rule_parameters: { 'threshold_price_tier_id' => price_tier.id } }
#       Given { promotion.update_columns(begins_at: Time.zone.now - 1.day, aasm_state: 2) }
#       Given { order.send(:calculate_price) }
#       Then { order.order_adjustments.size == 0 }
#     end
#   end
# end
