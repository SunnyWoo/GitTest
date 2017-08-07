require 'spec_helper'

describe Payment::Redeem do
  let!(:redeem_work) { create(:work, :redeem) }
  before { create_basic_currencies }
  describe '#pay' do
    it 'set order status to paid' do
      coupon = create(:coupon, condition: 'simple',
                               coupon_rules: [create(:work_rule, work_gids: [redeem_work.to_gid_param])])
      order = create(:order, :with_redeem, currency: 'TWD')
      order.tap(&:reload)
      order.order_items.first.update itemable: redeem_work
      order.tap(&:reload)
      order.coupon = coupon
      order.payment_object.pay
      expect(order.payment).to eq('redeem')
      expect(order.aasm_state).to eq('paid')
    end

    it 'return redeem_fail when without coupon code' do
      order = create(:order, :with_redeem)
      order.tap(&:reload)
      order.order_items.first.update itemable: redeem_work
      order.tap(&:reload)
      order.payment_object.pay
      expect(order.payment).to eq('redeem')
      expect(order.aasm_state).to eq('pending')
    end
  end

  describe '#valid?' do
    it 'returns false when order_item more then one' do
      order = create(:order, :with_redeem)
      create(:order_item, :with_redeem_work, order: order)
      order.reload
      order.coupon = create(:coupon, work_gids: [redeem_work.to_gid_param])
      expect(order.payment_object.send(:valid?)).to eq false
    end

    it 'returns false without coupon' do
      order = create(:order, :with_redeem)
      expect(order.reload.payment_object.send(:valid?)).to eq false
    end

    it 'returns false with non-redeem work' do
      order = create(:order, :with_redeem)
      create(:order_item, order: order)
      order.reload
      order.coupon = create :coupon
      expect(order.payment_object.send(:valid?)).to eq false
    end

    it 'returns true when everything is fine' do
      order = create(:order, :with_redeem)
      order.reload # 非常神奇，會自己產生order_item.....
      order.order_items.first.itemable.update work_type: :redeem
      order.coupon = create(:coupon, condition: 'simple',
                                     coupon_rules: [create(:work_rule, work_gids: [order.order_items.first.itemable.to_gid_param])])
      expect(order.payment_object.send(:valid?)).to eq true
    end
  end
end
