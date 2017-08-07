require 'spec_helper'

RSpec.describe 'api/v3/my/orders/price.json.jbuilder', type: :view do
  Given(:coupon) { create(:coupon) }
  Given(:work) { create(:work) }
  Given(:cart_params) do
    {
      currency: current_currency_code,
      coupon_code: coupon.code,
      items: [{
        type: 'shop',
        work_uuid: work.uuid,
        quantity: 2
      }, {
        type: 'create',
        product_model_key: ProductModel.first.key,
        quantity: 3
      }],
      shipping_info: {
        shipping_way: 'standard'
      }
    }.with_indifferent_access
  end

  Given do
    allow(view).to receive(:currency_code_precision).with("USD").and_return(2)
    allow(view).to receive(:currency_code_precision).with("TWD").and_return(0)
    allow(view).to receive(:current_currency_code).and_return(current_currency_code)
  end

  Given(:order) do
    record = build(:order).tap { |x| x.build_tmp_order(cart_params) }
    Api::V3::OrderDecorator.new(record)
  end
  Given(:order_json){ JSON.parse(rendered)['order'] }
  Given(:current_currency_code){ 'USD' }

  context 'renders order' do
    When do
      order.stub(:pricing_identifier).and_return('bf53b9c3fbb4434af85e8a3c06b70abb')
      assign(:order, order)
      render
    end
    Then do
      expect(JSON.parse(rendered)).to eq(
        'order' => {
          'currency' => order.currency,
          'coupon' => coupon.code,
          'price' => {
            'subtotal' => order.subtotal.as_json,
            'discount' => order.discount.as_json,
            'shipping_fee' => order.shipping_fee.as_json,
            'price' => order.price.as_json,
            'expired_at' => nil,
            'identifier' => 'bf53b9c3fbb4434af85e8a3c06b70abb',
            'valid' => true
          },
          'display_price' => {
            'subtotal' => view.render_price(order.subtotal),
            'discount' => view.render_price(order.discount),
            'shipping_fee' => view.render_price(order.shipping_fee),
            'price' => view.render_price(order.price)
          },
        },
        'meta' => {
          'items_count' => 5
        }
      )
    end
    And { expect(order_json['display_price']['price']).to eq '$494.50' }
  end

  context 'renders order with TWD as currency' do
    Given(:current_currency_code){ 'TWD' }
    When do
      assign(:order, order)
      render
    end
    Then { expect(order_json['currency']).to eq 'TWD' }
    And { expect(order_json['display_price']['price']).to eq 'NT$14,845' }
  end

  context 'renders order without coupon' do
    Given(:cart_params_without_coupon){ cart_params.merge(coupon_code: '') }
    Given(:order) do
      record = build(:order).tap { |x| x.build_tmp_order(cart_params_without_coupon) }
      Api::V3::OrderDecorator.new(record)
    end
    When do
      assign(:order, order)
      render
    end
    Then { expect(order_json['coupon']).to eq('') }
  end
end
