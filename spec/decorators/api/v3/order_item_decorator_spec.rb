require 'spec_helper'

describe Api::V3::OrderItemDecorator do
  Given { Order.any_instance.stub(:calculate_price) }
  Given(:work) do
    create(:work).tap do |w|
      w.stub(:original_prices).and_return("TWD" => 2999.0, "USD" => 99.0)
      w.stub(:prices).and_return("TWD" => 1999.0, "USD" => 59.0)
    end
  end
  Given(:prices) { original_item.prices }
  Given(:original_prices) { original_item.original_prices }
  Given(:order) { create :order, currency: 'TWD' }
  Given(:original_item) { create :order_item, order: order, quantity: 3 }
  Given(:item) { ActiveType.cast(original_item, OrderItem::ForPricing) }
  Given(:decorator) { Api::V3::OrderItemDecorator.new(item) }

  Given {
    original_item.update_attributes(
      prices: { "TWD" => 1999.0, "USD" => 59.0 },
      original_prices: { "TWD" => 2999.0, "USD" => 99.0 }
    )
    create_basic_currencies
  }

  describe '.spread_by_coupon_discount' do
    context 'coupon applied on special price will not spread the items' do
      Given(:coupon) { create :coupon, base_price_type: 'special' }
      Given!(:coupon_discount) { create :adjustment, order: order, source: coupon, adjustable: original_item, value: -10, quantity: 1 }
      When(:items) { Api::V3::OrderItemDecorator.spread_by_coupon_discount(original_item) }
      Then { expect(items.size).to eq 1 }
      And { expect(items[0].selling_price.value).to eq 1999.0 }
    end

    context 'coupon applied on original price' do
      Given(:coupon) { create :coupon, base_price_type: 'original' }
      Given!(:coupon_discount) { create :adjustment, order: order, source: coupon, adjustable: original_item, value: -10, quantity: 1, target: 'original' }
      When(:items) { Api::V3::OrderItemDecorator.spread_by_coupon_discount(original_item) }
      Then { expect(items.size).to eq 2 }
      And { expect(items[0].selling_price.value).to eq 1999.0 }
      And { expect(items[1].selling_price.value).to eq 2999.0 }

      context 'but the product has same prices on original and special' do
        Given {
          original_item.update_attributes(
            prices: { "TWD" => 699.0, "USD" => 22.0 },
            original_prices: { "TWD" => 699.0, "USD" => 22.0 }
          )
        }
        Then { expect(items.size).to eq 1 }
        And { expect(items[0].selling_price.value).to eq 699.0 }
      end
    end
  end

  context 'normal item use, use special price as selling price' do
    describe '#selling_price' do
      Then { expect(decorator.selling_price).to be_kind_of(Price) }
      And { expect(decorator.selling_price.value).to eq prices['TWD'] }
    end

    describe '#price_in_currency' do
      Then { expect(decorator.price_in_currency('USD')).to eq prices['USD'] }
    end

    describe '#subtotal' do
      Then { expect(decorator.subtotal).to eq prices['TWD'] * 3 }
    end
  end

  context 'with promotion adjustment' do
    Given(:promotion) { create :standardized_work_promotion }
    Given!(:adjustment) { create :adjustment, order: order, source: promotion, adjustable: original_item, value: -60 }

    describe '#selling_price' do
      Then { expect(decorator.selling_price.value).to eq prices['TWD'] - 60 }
    end

    describe '#price_in_currency' do
      Given(:currency_conversion) { currency_conversion_rate('TWD', 'USD') }
      Given(:ans) { decorator.price_in_currency('USD').round(2) }
      Then { expect(ans).to eq(((prices['TWD'] - 60) * currency_conversion).round(2)) }
    end
  end

  context 'with coupon discount' do
    Given(:coupon) { create :coupon, base_price_type: price_type }
    Given!(:coupon_discount) { create :adjustment, order: order, source: coupon, adjustable: original_item, value: -10 }
    context 'applied on original price' do
      Given(:price_type) { 'original' }
      Given { item.coupon_discount = coupon_discount }

      describe '#selling_price' do
        Then { expect(decorator.selling_price.value).to eq original_prices['TWD'] }
      end
    end

    context 'applied on special price' do
      Given(:price_type) { 'special' }
      Given { item.coupon_discount = coupon_discount }

      describe '#selling_price' do
        Then { expect(decorator.selling_price.value).to eq prices['TWD'] }
      end
    end
  end

  context 'with coupon discount and adjustment discount' do
    Given(:coupon) { create :coupon, base_price_type: price_type }
    Given(:promotion) { create :standardized_work_promotion }
    Given!(:coupon_discount) { create :adjustment, order: order, source: coupon, adjustable: original_item, value: -10 }
    Given!(:adjustment) { create :adjustment, order: order, source: promotion, adjustable: original_item, value: -60 }
    Given!(:adjustment2) { create :adjustment, order: order, source: promotion, adjustable: original_item, value: -30, target: 'original' }
    context 'applied on original price' do
      Given(:price_type) { 'original' }
      Given { item.coupon_discount = coupon_discount }

      describe '#selling_price' do
        Then { expect(decorator.selling_price.value).to eq original_prices['TWD'] - 30 }
      end
    end

    context 'applied on special price' do
      Given(:price_type) { 'special' }
      Given { item.coupon_discount = coupon_discount }

      describe '#selling_price' do
        Then { expect(decorator.selling_price.value).to eq prices['TWD'] - 60 }
      end
    end
  end
end
