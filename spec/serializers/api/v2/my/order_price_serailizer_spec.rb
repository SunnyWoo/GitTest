require 'spec_helper'

describe Api::V2::OrderPriceSerializer do
  before do
    create(:usd_currency_type)
  end

  it 'works' do
    order = create(:order)
    json = JSON.parse(Api::V2::OrderPriceSerializer.new(order, root: 'order').to_json)
    expect(json).to eq(
      'order' => {
        'currency' => 'USD',
        'coupon' => '',
        'price' => { 'subtotal' => '0.0',
                     'discount' => '0.0',
                     'shipping_fee' => '0.0',
                     'price' => 0.0
                   },
        'display_price' => { 'subtotal' => '$0.00',
                     'discount' => '$0.00',
                     'shipping_fee' => '$0.00',
                     'price' => '$0.00'
                   }
      }
    )
  end
end
