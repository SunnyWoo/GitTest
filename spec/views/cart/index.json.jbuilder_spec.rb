require 'spec_helper'

RSpec.describe 'cart/index.json.jbuilder', type: :view do
  let(:order) do
    create(:order, order_items: [create(:order_item)])
  end

  it 'renders cart' do
    assign(:order, order)
    render
    expect(rendered).to eq({
      'cart' => {
        'price' => view.render_price(order.price, currency_code: order.currency),
        'subtotal' => render_price(order.subtotal, currency_code: order.currency),
        'shipping_fee' => render_price(order.shipping_price, currency_code: order.currency),
        'discount' => render_price(order.discount, currency_code: order.currency),
        'coupon_code' => order.embedded_coupon.try(:code),
        'order_item_quantity_total' => order.order_items.inject(0) { |sum, item| sum + item.quantity },
        'payment' => order.payment,
        'payment_path' => view.begin_payment_path(order.payment_method),
        'shipping_info_shipping_way' => order.shipping_info_shipping_way,
        'order_items' => order.order_items.map do |order_item|
          {
            'uuid' => order_item.itemable.uuid,
            'name' => order_item.itemable.name,
            'model_name' => order_item.itemable.product_name,
            'order_image' => order_item.itemable.order_image.url,
            'order_image_thumb' => order_item.itemable.order_image.thumb.url,
            'quantity' => order_item.quantity,
            'price' => order_item.itemable.price_in_currency(order.currency),
            'subtotal' => render_price(order_item.price_in_currency(order.currency) * order_item.quantity,
                                       currency_code: order.currency),
            'del_path' => cart_path(id: order_item.itemable.uuid)
          }
        end,
        'currency' => order.currency,
        'billing_info' => {
          'address' => order.billing_info.address,
          'city' => order.billing_info.city,
          'name' => order.billing_info.name,
          'phone' => order.billing_info.phone,
          'state' => order.billing_info.state,
          'zip_code' => order.billing_info.zip_code,
          'country' => order.billing_info.country,
          'created_at' => order.billing_info.created_at,
          'updated_at' => order.billing_info.updated_at,
          'country_code' => order.billing_info.country_code,
          'shipping_way' => order.billing_info.shipping_way,
          'email' => order.billing_info.email
        },
        'shipping_info' => {
          'address' => order.shipping_info.address,
          'city' => order.shipping_info.city,
          'name' => order.shipping_info.name,
          'phone' => order.shipping_info.phone,
          'state' => order.shipping_info.state,
          'zip_code' => order.shipping_info.zip_code,
          'country' => order.shipping_info.country,
          'created_at' => order.shipping_info.created_at,
          'updated_at' => order.shipping_info.updated_at,
          'country_code' => order.shipping_info.country_code,
          'shipping_way' => order.shipping_info.shipping_way,
          'email' => order.shipping_info.email
        }
      }}.to_json
    )
  end
end
