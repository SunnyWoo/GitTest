require 'spec_helper'

describe ShippingFeeService do
  describe 'shipping from global' do
    before do
      stub_env('REGION', 'global')
      ImportShippingFeeService.import_global_shipping_fee
      allow_any_instance_of(Order).to receive(:weight).and_return(13_000)
      create :usd_currency_type
      create :twd_currency_type
    end
    context 'shipping to US' do
      Given(:shipping_info) { create :shipping_info, country_code: 'US' }
      Given!(:order) { create :order, shipping_info: shipping_info }
      Then { ShippingFeeService.new(order).price == CurrencyExchangeService.new(4310, 'TWD', 'USD').execute }
    end

    context 'shipping to TW ' do
      Given do
        fee = create(:fee, name: 'global_to_tw_price')
        fee.currencies.find_by(code: 'USD').update(price: 2)
        fee.currencies.find_by(code: 'TWD').update(price: 65)
      end
      Given(:shipping_info) { create :shipping_info, country_code: 'TW' }

      context 'when currency is TWD' do
        Given!(:order) { create :order, currency: 'TWD', shipping_info: shipping_info }
        Given { order.update_column(:subtotal, 300) }
        Then { Fee.find_by(name: 'global_to_tw_price').present? }
        And { ShippingFeeService.new(order).price == 65 }
      end

      context 'when currency is USD' do
        Given!(:order) { create :order, currency: 'USD', shipping_info: shipping_info }
        Given { order.update_column(:subtotal, 300) }
        Then { Fee.find_by(name: 'global_to_tw_price').present? }
        And { ShippingFeeService.new(order).price == 2 }
      end
    end
  end

  describe 'shipping from china' do
    before do
      stub_env('REGION', 'china')
      ImportShippingFeeService.import_china_shipping_fee
      allow_any_instance_of(Order).to receive(:weight).and_return(13_000)
      create :cny_currency_type
    end
    context 'shipping to shanghai' do
      Given(:province) { Province.find_by_name('上海市') }
      Given(:shipping_info) { create :shipping_info, country_code: 'CN', province: province }
      Given!(:order) { create :order, currency: 'CNY', shipping_info: shipping_info }
      Then { ShippingFeeService.new(order).price == 18 }
    end

    context 'shipping to special province with express' do
      Given(:province) { Province.find_by_name('江苏省') }
      Given(:shipping_info) { create :shipping_info, shipping_way: 1, country_code: 'CN', province: province, city: '徐州市' }
      Given!(:order) { create :order, currency: 'CNY', shipping_info: shipping_info }
      Then { ShippingFeeService.new(order).price == 88 }
    end

    context 'shipping with specified shipping_way' do
      Given(:province) { Province.find_by_name('上海市') }
      Given(:shipping_info) { create :shipping_info, country_code: 'CN', province: province }
      Given!(:order) { create :order, currency: 'CNY', shipping_info: shipping_info }
      Then { ShippingFeeService.new(order).price == 18 }
      And { ShippingFeeService.new(order, nil, 'express').price == 36 }
    end

    context 'order payment with nuandao_b2b' do
      Given(:order) { create :order, :with_nuandao_b2b }
      Then { ShippingFeeService.new(order).price == 0 }
    end
  end
end
