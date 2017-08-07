require 'spec_helper'

describe StripeService do
  before do
    CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
    CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
  end

  context '#calculate_price_with_currency' do
    it 'order price with currency US' do
      model = create(:product_model, name: 'iPhone 6', price_table: { 'JPY' => 2500,
                                                                      'USD' => 160.30,
                                                                      'HKD' => 120,
                                                                      'TWD' => 500 })
      work = create(:work, model: model)
      order = create(:order, payment: 'stripe', currency: 'USD')
      order.order_items = [OrderItem.create(itemable: work, quantity: 1)]
      order.save
      stripe_service = StripeService.new(order, stripe_token: 'gg')
      expect(stripe_service.send('calculate_price_with_currency')).to eq 16_030
    end

    it 'order price with cent with currency US' do
      model = create(:product_model, name: 'iPhone 6', price_table: { 'JPY' => 2500,
                                                                      'USD' => 160.20,
                                                                      'HKD' => 120,
                                                                      'TWD' => 500 })
      work = create(:work, model: model)
      order = create(:order, payment: 'stripe', currency: 'USD')
      order.order_items = [OrderItem.create(itemable: work, quantity: 1)]
      order.save
      stripe_service = StripeService.new(order, stripe_token: 'gg')
      expect(stripe_service.send('calculate_price_with_currency')).to eq 16_020
    end

    it 'order price with currency JPY' do
      model = create(:product_model, name: 'iPhone 6', price_table: { 'JPY' => 2500,
                                                                      'USD' => 29.00,
                                                                      'HKD' => 120,
                                                                      'TWD' => 500 })
      work = create(:work, model: model)
      order = create(:order, payment: 'stripe', currency: 'JPY')
      order.order_items = [OrderItem.create(itemable: work, quantity: 1)]
      order.save
      stripe_service = StripeService.new(order, stripe_token: 'gg')
      expect(stripe_service.send('calculate_price_with_currency')).to eq 2500
    end

    it 'order price with currency HKD' do
      model = create(:product_model, name: 'iPhone 6', price_table: { 'JPY' => 2500,
                                                                      'USD' => 29.00,
                                                                      'HKD' => 120,
                                                                      'TWD' => 500 })
      work = create(:work, model: model)
      order = create(:order, payment: 'stripe', currency: 'HKD')
      order.order_items = [OrderItem.create(itemable: work, quantity: 1)]
      order.save
      stripe_service = StripeService.new(order, stripe_token: 'gg')
      expect(stripe_service.send('calculate_price_with_currency')).to eq 12_000
    end

    it 'order price with currency TWD' do
      model = create(:product_model, name: 'iPhone 6', price_table: { 'JPY' => 2500,
                                                                      'USD' => 29.00,
                                                                      'HKD' => 120,
                                                                      'TWD' => 500.0 })
      work = create(:work, model: model)
      order = create(:order, payment: 'stripe', currency: 'TWD')
      order.order_items = [OrderItem.create(itemable: work, quantity: 1)]
      order.save
      stripe_service = StripeService.new(order, stripe_token: 'gg')
      expect(stripe_service.send('calculate_price_with_currency')).to eq 50_000
    end
  end
end
