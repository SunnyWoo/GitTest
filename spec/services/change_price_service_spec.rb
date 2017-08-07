require 'spec_helper'

describe ChangePriceService do
  describe '#execute' do
    context 'when change standardized_work price' do
      Given(:work) { create :standardized_work }
      Given(:event) { create :change_price_event, :with_standardized_work_price, target_ids: [work.id] }
      When { ChangePriceService.new(event.id).execute }
      Then { event.change_price_histories.size == 1 }
      And { work.reload.change_price_histories.size == 1 }
      And { work.reload.price_tier_id == event.price_tier_id }
    end

    context 'when change product_model price' do
      Given(:product) { create :product_model }
      Given(:event) { create :change_price_event, :with_product_price, target_ids: [product.id] }
      When { ChangePriceService.new(event.id).execute }
      Then { event.change_price_histories.size == 1 }
      And { product.reload.change_price_histories.size == 1 }
      And { product.reload.price_tier_id == event.price_tier_id }
    end

    context 'when change product_model customized_price' do
      Given(:product) { create :product_model }
      Given(:event) { create :change_price_event, :with_product_customized_price, target_ids: [product.id] }
      When { ChangePriceService.new(event.id).execute }
      Then { event.change_price_histories.size == 1 }
      And { product.reload.change_price_histories.size == 1 }
      And { product.reload.customized_special_price_tier_id == event.price_tier_id }
    end
  end
end
