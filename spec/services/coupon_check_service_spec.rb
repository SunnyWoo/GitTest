require 'spec_helper'

describe CouponCheckService do
  context '#can_use?' do
    Given(:service) { CouponCheckService.new(coupon, user: order.user, order: order) }
    context 'when is_not_include_promotion is true' do
      Given(:coupon) { create(:coupon, is_not_include_promotion: true) }
      Given(:promotion) { create :order_price_promotion, aasm_state: :started }
      Given(:promotion2) { create :order_price_promotion, aasm_state: :started }
      Given(:order) { create :order }

      context 'returns true with not available promotion' do
        Given { promotion.stub(:applicable?).with(order).and_return(false) }
        Given { promotion2.stub(:applicable?).with(order).and_return(false) }
        Given { Promotion.stub(:available).and_return([promotion, promotion2]) }
        Then { service.pass? == true }
      end

      context 'returns true with available promotion' do
        Given { promotion.stub(:applicable?).with(order).and_return(true) }
        Given { promotion2.stub(:applicable?).with(order).and_return(false) }
        Given { Promotion.stub(:available).and_return([promotion, promotion2]) }
        Then { service.pass? == true }
      end

      context 'returns false with available promotion' do
        Given { promotion.stub(:applicable?).with(order).and_return(true) }
        Given { promotion2.stub(:applicable?).with(order).and_return(true) }
        Given { Promotion.stub(:available).and_return([promotion, promotion2]) }
        Then { service.pass? == true }
      end
    end

    context 'when is_not_include_promotion is false' do
      Given(:coupon) { create(:coupon, is_not_include_promotion: false) }
      Given(:promotion) { create :order_price_promotion, aasm_state: :started }
      Given(:order) { create :order }

      context 'returns true with not available promotion' do
        Given { promotion.stub(:applicable?).with(order).and_return(false) }
        Given { Promotion.stub(:available).and_return([promotion]) }
        Then { service.pass? == true }
      end

      context 'returns true with available promotion' do
        Given { promotion.stub(:applicable?).with(order).and_return(true) }
        Given { Promotion.stub(:available).and_return([promotion]) }
        Then { service.pass? == true }
      end
    end
  end

  context '#reach_limit_by_user?' do
    context 'with a user' do
      Given(:user) { create :user }
      Given(:coupon) { create :coupon, user_usage_count_limit: 1 }
      Given(:order) { create :order, user: user, coupon: coupon }
      Given(:service) { CouponCheckService.new(coupon, user: user, order: order) }

      it 'returns false when not reaching the limit of per user usage' do
        expect(service.reach_limit_by_user?).to eq false
      end

      it 'returns true when reaching the limit of per user usage' do
        create :paid_order, user: user, coupon: coupon
        expect(service.reach_limit_by_user?).to eq true
      end

      it 'returns true when reaching the limit of per user usage for the case of delay_payments' do
        create :order, :with_atm, user: user, coupon: coupon
        expect(service.reach_limit_by_user?).to eq true
      end

      context 'returns true when reaching the limit of per user usage for both delay or non-delay payments' do
        Given(:coupon) { create :coupon, user_usage_count_limit: 2 }
        before do
          create :paid_order, user: user, coupon: coupon
          create :order, :with_atm, user: user, coupon: coupon
        end
        it { expect(service.reach_limit_by_user?).to eq true }
      end
    end

    context 'without any user' do
      it 'returns true when user_usage_count_limit not equal to -1' do
        coupon = create :coupon, user_usage_count_limit: 1
        order = create :order, coupon: coupon
        service = CouponCheckService.new(coupon, user: nil, order: order)
        expect(service.reach_limit_by_user?).to eq true
      end

      it 'returns false when user_usage_count_limit equal to -1' do
        coupon = create :coupon, user_usage_count_limit: -1
        order = create :order, coupon: coupon
        service = CouponCheckService.new(coupon, user: nil, order: order)
        expect(service.reach_limit_by_user?).to eq false
      end
    end
  end

  describe '#forbidden_scope?' do
    Given(:user) { create :user }
    Given(:coupon){ create(:coupon, code: '123') }
    Given(:child_coupon){ create(:coupon, parent: coupon) }
    Given(:order) { Order.new }
    Given(:service) { CouponCheckService.new coupon, user: user, order: order }

    context 'determine with forbidden event' do
      Given(:event) { double(CouponForbiddenEvent) }
      Given { allow(CouponForbiddenEvent).to receive(:active).and_return [event] }

      context 'which is blocking' do
        Given { allow(event).to receive(:blocking?).and_return true }
        Then { service.forbidden_scope? == true }
      end

      context 'child_coupon which is blocking' do
        Given { allow(event).to receive(:blocking?).and_return true }
        Then { service.forbidden_scope? == true }
      end

      context 'which is not blocking' do
        Given { allow(event).to receive(:blocking?).and_return false }
        Then { service.forbidden_scope? == false }
      end
    end

    context 'without passing order information' do
      Given(:order) { nil }
      Then { service.forbidden_scope? == false }
    end
  end

  context '#pass_with series' do
    Given(:coupon) { create(:coupon, condition: 'simple', coupon_rules: [coupon_rule]) }
    Given(:coupon_child) { coupon.create_unique_coupon_child }
    Given(:user) { create :user }
    Given(:service) { CouponCheckService.new(coupon, user: user) }
    Given(:child_service) { CouponCheckService.new(coupon_child, user: user) }

    describe '#pass_with_redeem_work?' do
      Given!(:work) { create :work, :redeem }
      Given(:coupon_rule) { create :work_rule, work_gids: [work.to_gid_param] }

      Then { service.pass_with_redeem_work?(work.to_gid_param) == true }
      And { child_service.pass_with_redeem_work?(work.to_gid_param) == true }
      And { service.pass_with_redeem_work?('xxxxx') == false }
      And { child_service.pass_with_redeem_work?('xxxxx') == false }
    end

    describe '#pass_with_bdevent?' do
      Given(:bdevent) { create :bdevent }
      Given(:coupon_rule) { create(:bdevent_rule, bdevent_id: bdevent.id) }

      Then { service.pass_with_bdevent?(bdevent.id) == true }
      And { child_service.pass_with_bdevent?(bdevent.id) == true }
      And { service.pass_with_bdevent?('654312') == false }
      And { child_service.pass_with_bdevent?('654312') == false }
    end

    describe '#pass_with_product?' do
      Given(:product) { create :product_model }
      Given(:coupon_rule) { create(:product_model_rule, product_model_ids: [product.id]) }
      Then { service.pass_with_product?(product.id) == true }
      And { child_service.pass_with_product?(product.id) == true }
      And { service.pass_with_product?('654312') == false }
      And { child_service.pass_with_product?('654312') == false }
    end
  end
end
