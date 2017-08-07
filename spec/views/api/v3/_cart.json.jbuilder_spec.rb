require 'spec_helper'

RSpec.describe 'api/v3/_cart.json.jbuilder', :caching, type: :view do
  let(:order) do
    o = create(:order, :priced)
    Api::V3::OrderDecorator.new(o)
  end

  it 'renders cart' do
    order.stub(:pricing_identifier).and_return('bf53b9c3fbb4434af85e8a3c06b70abb')
    render 'api/v3/cart', order: order
    expect(JSON.parse(rendered)).to eq(
      'price' => view.render_price(order.price, currency_code: order.currency),
      'subtotal' => render_price(order.subtotal, currency_code: order.currency),
      'shipping_fee' => render_price(order.shipping_price, currency_code: order.currency),
      'discount' => render_price(order.discount, currency_code: order.currency),
      'order_price' => {
        "subtotal" => "99.9",
        "discount" => "0.0",
        "shipping_fee" => "0.0",
        "price" => 99.9,
        "expired_at" => nil,
        "identifier" => "bf53b9c3fbb4434af85e8a3c06b70abb",
        "valid" => true
      },
      'display_price' => {
        'subtotal' => render_price(order.subtotal, currency_code: order.currency),
        'discount' => render_price(order.discount, currency_code: order.currency),
        'shipping_fee' => render_price(order.shipping_price, currency_code: order.currency),
        'price_without_shipping_fee' => render_price(order.price_without_shipping_fee, currency_code: order.currency),
        'price' => view.render_price(order.price, currency_code: order.currency),
      },
      'coupon_code' => order.embedded_coupon.try(:code),
      'order_item_quantity_total' => order.order_items.inject(0) { |sum, item| sum + item.quantity },
      'payment' => order.payment,
      'payment_path' => view.begin_payment_path(order.payment_method),
      'shipping_info_shipping_way' => order.shipping_info_shipping_way,
      'order_items' => order.order_items.map do |order_item|
        work = order_item.itemable
        {
          'item' => {
            'id' => work.id,
            'gid' => work.to_gid_param,
            'uuid' => work.uuid,
            'name' => work.name,
            'user_avatar' => work.user_avatar.as_json.deep_stringify_keys,
            'user_id' => work.user_id,
            'order_image' => {
              'thumb' => work.order_image.thumb.url,
              'share' => work.order_image.share.url,
              'sample' => work.order_image.sample.url,
              'normal' => work.order_image.url
            },
            'gallery_images' => work.ordered_previews.map do |preview|
              {
                'normal' => preview.image.url,
                'thumb' => preview.image.thumb.url
              }
            end,
            'prices' => work.prices.to_h,
            'original_prices' => work.original_prices.to_h,
            'user_display_name' => work.user_display_name,
            'wishlist_included' => false,
            'slug' => work.slug,
            'is_public' => work.is_public?,
            'user_avatars' => {
              's35' => work.user.avatar.s35.url,
              's154' => work.user.avatar.s154.url
            },
            'spec' => {
              'id' => work.product.id,
              'name' => work.product.name,
              'description' => work.product.description,
              'width' => work.product.width,
              'height' => work.product.height,
              'dpi' => work.product.dpi,
              'background_image' => work.product.background_image.url,
              'overlay_image' => work.product.overlay_image.url,
              'padding_top' => work.product.padding_top.to_s,
              'padding_right' => work.product.padding_right.to_s,
              'padding_bottom' => work.product.padding_bottom.to_s,
              'padding_left' => work.product.padding_left.to_s,
              '__deprecated' => 'WorkSpec is not longer available'
            },
            'model' => {
              'id' => work.product.id,
              'key' => work.product.key,
              'name' => work.product.name,
              'description' => work.product.description,
              'prices' => work.product.prices,
              'customized_special_prices' => work.product.customized_special_prices,
              'design_platform' => work.product.design_platform,
              'customize_platform' => work.product.customize_platform,
              'placeholder_image' => work.product.placeholder_image.url,
              'width' => work.product.width,
              'height' => work.product.height,
              'dpi' => work.product.dpi,
              'background_image' => work.product.background_image.url,
              'overlay_image' => work.product.overlay_image.url,
              'padding_top' => work.product.padding_top.to_s,
              'padding_right' => work.product.padding_right.to_s,
              'padding_bottom' => work.product.padding_bottom.to_s,
              'padding_left' => work.product.padding_left.to_s
            },
            'product' => {
              'id' => work.product.id,
              'key' => work.product.key,
              'name' => work.product.name,
              'description' => work.product.description,
              'prices' => work.product.prices,
              'customized_special_prices' => work.product.customized_special_prices,
              'design_platform' => work.product.design_platform,
              'customize_platform' => work.product.customize_platform,
              'placeholder_image' => work.product.placeholder_image.url,
              'width' => work.product.width,
              'height' => work.product.height,
              'dpi' => work.product.dpi,
              'background_image' => work.product.background_image.url,
              'overlay_image' => work.product.overlay_image.url,
              'padding_top' => work.product.padding_top.to_s,
              'padding_right' => work.product.padding_right.to_s,
              'padding_bottom' => work.product.padding_bottom.to_s,
              'padding_left' => work.product.padding_left.to_s
            },
            'category' => {
              'id' => work.category.id,
              'key' => work.category.key,
              'name' => work.category.name
            },
            'featured' => work.featured?,
            'tags' => work.tags.each do |tag|
              {
                'id' => tag.id,
                'name' => tag.name,
                'text' => tag.text
              }
            end
          },
          'quantity' => order_item.quantity
        }
      end,
      'currency' => order.currency
    )
  end
end
