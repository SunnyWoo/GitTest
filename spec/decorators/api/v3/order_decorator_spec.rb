require 'spec_helper'

describe Api::V3::OrderDecorator do
  Given(:order_state) { 'paid' }
  Given(:order) { create :order, aasm_state: order_state }
  Given(:decorator) { Api::V3::OrderDecorator.new(order) }
  Given(:promotion){ create :standardized_work_promotion }

  describe '#payment_info' do
    Given { order.update_attribute(:payment_info, payment_id: 'foo') }

    context 'with payment is not atm' do
      Given do
        order.payment = 'paypal'
        order.save
      end
      Then { expect(decorator.payment_info).to eq('method' => 'paypal', 'payment_id' => 'foo') }
    end

    context 'with payment it atm' do
      Given do
        order.payment = 'neweb/atm'
        allow(order).to receive(:payment_object).and_return(
          OpenStruct.new('bank_id' => 'bar', 'bank_name' => 'zoo')
        )
        order.save
      end
      Then do
        expect(decorator.payment_info).to eq(
          'method' => 'neweb/atm',
          'payment_id' => 'foo',
          'bank_id' => 'bar',
          'bank_name' => 'zoo'
        )
      end
    end
  end

  describe '#defered_adjusted?' do
    Given(:ans) { decorator.deferred_adjusted? }
    Given { allow(order).to receive(:base_price_type).and_return('original') }

    context 'with adjustment event of fallback' do
      Given {
        create :adjustment, :apply, order: order, source: promotion, target: 'original'
        create :adjustment, :fallback, order: order, source: promotion, target: 'original'
      }
      Then { expect(ans).to eq true }
    end

    context 'with adjustment event of supply' do
      Given{ create :adjustment, :supply, order: order, source: promotion, target: 'original' }
      Then { expect(ans).to eq true }
    end

    context 'with adjustment event of apply only' do
      Given { create :adjustment, :apply, order: order, source: promotion, target: 'original' }
      Then { expect(ans).to eq false }
    end
  end

  describe '#pricing_identifier' do
    Given do
      allow(order).to receive(:base_price_type).and_return('original')
      create :adjustment, :apply, order: order, source: promotion, target: 'original'
    end
    context 'should compose by id, pricing target, price and actual adjustments' do
      Given {
        allow(Digest::MD5).to receive(:hexdigest).with("#{order.id}-original-#{order.price}-1").and_return('foo')
      }
      Then { expect(decorator.pricing_identifier).to eq 'foo' }
    end

    context 'should become different once' do
      context 'price changed' do
        Then do
          expect {
            order.update_attributes(price: 99_999)
          }.to change { Api::V3::OrderDecorator.new(order.reload).pricing_identifier }
        end
      end

      context 'price type changed' do
        Then do
          expect {
            order.stub(:base_price_type).and_return('special')
          }.to change { Api::V3::OrderDecorator.new(order.reload).pricing_identifier }
        end
      end

      context 'adjustments changed' do
        Then do
          expect {
            create :adjustment, :fallback, order: order, source: promotion, target: 'original'
          }.to change { Api::V3::OrderDecorator.new(order.reload).pricing_identifier }
        end
      end
    end
  end

  describe '#pricing_expired_at' do
    context 'for order with state of pending' do
      Given(:order_state) { 'pending' }
      Then { expect(decorator.pricing_expired_at).to eq nil }
    end

    context 'for other state, retrieve state by checking #recent_ending_promotion_expiration' do
      Given { allow(decorator).to receive(:recent_ending_promotion_expiration).and_return('foo') }
      Then { expect(decorator.pricing_expired_at).to eq 'foo' }
    end
  end

  describe '#deferred_adjustments' do
    Given(:price_type) { 'original' }
    Given { allow(order).to receive(:base_price_type).and_return(price_type) }

    context 'excluded records with apply event' do
      When { create :adjustment, :apply, order: order, source: promotion, target: 'original' }
      Then { expect(decorator.deferred_adjustments.size).to eq 0 }
      And { expect(decorator.deferred_adjustments).to be_empty }
    end

    context 'included records except apply event' do
      Given!(:a1) { create :adjustment, :apply, order: order, source: promotion, target: 'original' }
      Given!(:a2) { create :adjustment, :fallback, order: order, source: promotion, target: 'original' }
      When(:adjustments) { decorator.deferred_adjustments }
      Then { expect(adjustments.size).to eq 1 }
      And { expect(adjustments).to match_array [a2] }
    end

    context 'included records with target matched' do
      Given!(:a1) { create :adjustment, :supply, order: order, source: promotion, target: 'original' }
      Given!(:a2) { create :adjustment, :supply, order: order, source: promotion, target: 'special' }
      Given!(:a3) { create :adjustment, :fallback, order: order, source: promotion, target: 'original' }
      When(:adjustments) { decorator.deferred_adjustments }
      Then { expect(adjustments.size).to eq 2 }
      And { expect(adjustments).to match_array [a1, a3] }
    end
  end
end
