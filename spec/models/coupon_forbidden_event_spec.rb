require 'rails_helper'

RSpec.describe CouponForbiddenEvent, type: :model do
  describe '#active?' do
    context 'within time range' do
      Given(:begins_at){ Time.zone.now.days_ago(10) }
      Given(:ends_at){ Time.zone.now.days_since(10) }
      Given(:event){ CouponForbiddenEvent.new(begins_at: begins_at, ends_at: ends_at) }
      Then { expect(event).to be_active }
    end

    context 'out of time range' do
      Given(:begins_at){ Time.zone.now.days_ago(10) }
      Given(:ends_at){ Time.zone.now.days_ago(5) }
      Given(:event){ CouponForbiddenEvent.new(begins_at: begins_at, ends_at: ends_at) }
      Then { expect(event).not_to be_active }
    end
  end

  describe '#blocking?' do
    Given(:event){ CouponForbiddenEvent.new(region: %w(china global)) }
    Given(:coupon) { double(Coupon) }
    Given(:user) { double(User) }
    Given(:order) { double(Order) }

    context 'when met both conditions of coupon and product line' do
      Given { allow(event).to receive(:blocked_on_coupon?).with(coupon).and_return(true) }
      Given { allow(event).to receive(:blocked_on_product_line?).with(order).and_return(true) }
      Then { expect(event.blocking?(coupon, order, user)).to eq true }
      And { expect(event).to have_received(:blocked_on_coupon?).with(coupon).exactly(1) }
      And { expect(event).to have_received(:blocked_on_product_line?).with(order).exactly(1) }
    end

    context 'coupon condition was not met' do
      Given { allow(event).to receive(:blocked_on_coupon?).with(coupon).and_return(true) }
      Given { allow(event).to receive(:blocked_on_product_line?).with(order).and_return(false) }
      Then { expect(event.blocking?(coupon, order, user)).to eq false }
      And { expect(event).to have_received(:blocked_on_coupon?).with(coupon).exactly(1) }
      And { expect(event).to have_received(:blocked_on_product_line?).with(order).exactly(1) }
    end

    context 'product line condition was not met' do
      Given { allow(event).to receive(:blocked_on_coupon?).with(coupon).and_return(false) }
      Given { allow(event).to receive(:blocked_on_product_line?).with(order).and_return(true) }
      Then { expect(event.blocking?(coupon, order, user)).to eq false }
      And { expect(event).to have_received(:blocked_on_coupon?).with(coupon).exactly(1) }
    end
  end

  describe '#blocked_on_coupon?' do
    Given(:event){ CouponForbiddenEvent.new(coupon_ids: %w(1 2 3)) }
    Given(:coupon){ double(Coupon).tap { |x| allow(x).to receive(:id).and_return(used_coupon_id) } }
    Given(:child_coupon){ double(Coupon).tap { |x| allow(x).to receive(:id).and_return(used_coupon_id) } }

    context 'in blocking list' do
      Given(:used_coupon_id){ 1 }
      Then { expect(event.blocked_on_coupon?(coupon)).to eq true }
    end

    context 'child_coupon in blocking list' do
      Given(:used_coupon_id){ 1 }
      Then { expect(event.blocked_on_coupon?(child_coupon)).to eq true }
    end

    context 'not in blocking list' do
      Given(:used_coupon_id){ 123 }
      Then { expect(event.blocked_on_coupon?(coupon)).to eq false }
    end
  end

  describe '#blocked_on_product_line?' do
    Given(:order){ double(Order) }

    context 'given blocked category_keys' do
      Given(:event){ CouponForbiddenEvent.new(category_keys: %w(case canvas)) }
      Given { allow(event).to receive(:extract_product_keys).with(order).and_return(%w(foo bar)) }
      context 'included in the blocked keys' do
        Given { allow(event).to receive(:extract_category_keys).with(order).and_return(%w(case pillow)) }
        Then { expect(event.blocked_on_product_line?(order)).to eq true }
      end

      context 'excluded the blocked keys' do
        Given { allow(event).to receive(:extract_category_keys).with(order).and_return(%w(usb pillow)) }
        Then { expect(event.blocked_on_product_line?(order)).to eq false }
      end
    end

    context 'given blocked product_keys' do
      Given(:event){ CouponForbiddenEvent.new(product_keys: %w(case canvas)) }
      Given { allow(event).to receive(:extract_category_keys).with(order).and_return(%w(foo bar)) }
      context 'included in the blocked keys' do
        Given { allow(event).to receive(:extract_product_keys).with(order).and_return(%w(case pillow)) }
        Then { expect(event.blocked_on_product_line?(order)).to eq true }
      end

      context 'excluded the blocked keys' do
        Given { allow(event).to receive(:extract_product_keys).with(order).and_return(%w(usb pillow)) }
        Then { expect(event.blocked_on_product_line?(order)).to eq false }
      end
    end
  end

  describe '#blocked_on_region?' do
    Given(:event){ CouponForbiddenEvent.new(region: region) }

    context 'when region at china' do
      before { stub_env('REGION', 'china') }

      context 'event region is china' do
        Given(:region){ ['china'] }
        Then { expect(event.blocked_on_region?).to eq true }
      end

      context 'event region is global' do
        Given(:region){ ['global'] }
        Then { expect(event.blocked_on_region?).to eq false }
      end

      context 'event region is global, china' do
        Given(:region){ %w(global china) }
        Then { expect(event.blocked_on_region?).to eq true }
      end
    end

    context 'when region at global' do
      before { stub_env('REGION', 'global') }

      context 'event region is china' do
        Given(:region){ ['china'] }
        Then { expect(event.blocked_on_region?).to eq false }
      end

      context 'event region is global' do
        Given(:region){ ['global'] }
        Then { expect(event.blocked_on_region?).to eq true }
      end

      context 'event region is global, china' do
        Given(:region){ %w(global china) }
        Then { expect(event.blocked_on_region?).to eq true }
      end
    end
  end
end
