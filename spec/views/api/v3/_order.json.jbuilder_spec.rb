require 'spec_helper'

RSpec.describe 'api/v3/_order.json.jbuilder', :caching, type: :view do
  let(:order) { create(:order) }
  let(:package) { double('Package', ship_code: '1234567', logistics_supplier_name: '圆通') }
  before do
    allow(order).to receive(:packages).and_return([package])
  end

  it 'renders order' do
    render 'api/v3/order', order: order
    expect(JSON.parse(rendered)).to eq(
      'uuid' => order.uuid,
      'price' => order.price,
      'currency' => order.currency,
      'status' => order.aasm_state.to_s,
      'status_i18n' => view.t("order.state.#{order.aasm_state}"),
      'payment' => order.payment,
      'payment_info' => order.payment_info,
      'coupon' => '',
      'order_price' => {
        'subtotal' => order.subtotal.as_json,
        'discount' => order.discount.as_json,
        'shipping_fee' => order.shipping_fee.as_json,
        'price' => order.price.as_json
      },
      'display_price' => {
        'subtotal' => view.render_price(order.subtotal, currency_code: order.currency),
        'discount' => view.render_price(order.discount, currency_code: order.currency),
        'shipping_fee' => view.render_price(order.shipping_fee, currency_code: order.currency),
        'price' => view.render_price(order.price, currency_code: order.currency)
      },
      'order_no' => order.order_no,
      'created_at' => order.created_at.as_json,
      'message' => order.message,
      'activities' => order.activities.where(key: %i(create paid shipped)).map do |activity|
        {
          'key' => activity.key,
          'created_at' => activity.created_at.as_json
        }
      end,
      'ship_code' => order.ship_code,
      'logistics_info' => [{ 'ship_code' => '1234567', 'logistics_supplier_name' => '圆通' }],
      'billing_info' => {
        'id' => order.billing_info.id,
        'address' => order.billing_info.address,
        'address_name' => order.billing_info.address_name,
        'city' => order.billing_info.city,
        'name' => order.billing_info.name,
        'phone' => order.billing_info.phone,
        'state' => order.billing_info.state,
        'dist' => order.billing_info.dist,
        'dist_code' => order.billing_info.dist_code,
        'province_id' => order.billing_info.province_id,
        'province' => order.billing_info.province_name,
        'province_name' => order.billing_info.province_name,
        'zip_code' => order.billing_info.zip_code,
        'country' => order.billing_info.country,
        'created_at' => order.billing_info.created_at.as_json,
        'updated_at' => order.billing_info.updated_at.as_json,
        'country_code' => order.billing_info.country_code,
        'shipping_way' => order.billing_info.shipping_way,
        'email' => order.billing_info.email
      },
      'shipping_info' => {
        'id' => order.shipping_info.id,
        'address' => order.shipping_info.address,
        'address_name' => order.shipping_info.address_name,
        'city' => order.shipping_info.city,
        'name' => order.shipping_info.name,
        'phone' => order.shipping_info.phone,
        'state' => order.shipping_info.state,
        'dist' => order.shipping_info.dist,
        'dist_code' => order.shipping_info.dist_code,
        'province_id' => order.shipping_info.province_id,
        'province' => order.shipping_info.province_name,
        'province_name' => order.shipping_info.province_name,
        'zip_code' => order.shipping_info.zip_code,
        'country' => order.shipping_info.country,
        'created_at' => order.shipping_info.created_at.as_json,
        'updated_at' => order.shipping_info.updated_at.as_json,
        'country_code' => order.shipping_info.country_code,
        'shipping_way' => order.shipping_info.shipping_way,
        'email' => order.shipping_info.email
      },
      'order_items' => order.order_items.map do |order_item|
        {
          'quantity' => order_item.quantity,
          'price' => order_item.price_in_currency(order_item.order.currency),
          'work_uuid' => order_item.itemable_uuid,
          'work_name' => order_item.itemable_name,
          'model_name' => order_item.itemable.product_name,
          'model_key' => order_item.itemable.product.key,
          'product_name' => order_item.itemable.product_name,
          'product_key' => order_item.itemable.product.key,
          'order_image' => order_item.itemable.order_image.thumb.url,
          'user_display_name' => order_item.itemable.user_display_name,
          'is_public' => order_item.itemable.is_public?
        }.merge JSON.parse(view.render('api/v3/unapproved_order_item', order_item: order_item))
      end
    )
  end

  context 'with coupon' do
    let(:order) { create(:order, :with_coupon) }
    let(:package) { double('Package', ship_code: '1234567', logistics_supplier_name: '圆通') }
    before do
      allow(order).to receive(:packages).and_return([package])
    end

    it 'renders order' do
      render 'api/v3/order', order: order
      expect(JSON.parse(rendered)).to eq(
        'uuid' => order.uuid,
        'price' => order.price,
        'currency' => order.currency,
        'status' => order.aasm_state.to_s,
        'status_i18n' => view.t("order.state.#{order.aasm_state}"),
        'payment' => order.payment,
        'payment_info' => order.payment_info,
        'coupon' => order.coupon.code,
        'order_price' => {
          'subtotal' => order.subtotal.as_json,
          'discount' => order.discount.as_json,
          'shipping_fee' => order.shipping_fee.as_json,
          'price' => order.price.as_json
        },
        'display_price' => {
          'subtotal' => view.render_price(order.subtotal, currency_code: order.currency),
          'discount' => view.render_price(order.discount, currency_code: order.currency),
          'shipping_fee' => view.render_price(order.shipping_fee, currency_code: order.currency),
          'price' => view.render_price(order.price, currency_code: order.currency)
        },
        'order_no' => order.order_no,
        'created_at' => order.created_at.as_json,
        'message' => order.message,
        'activities' => order.activities.where(key: %i(create paid shipped)).map do |activity|
          {
            'key' => activity.key,
            'created_at' => activity.created_at.as_json
          }
        end,
        'ship_code' => order.ship_code,
        'logistics_info' => [{ 'ship_code' => '1234567', 'logistics_supplier_name' => '圆通' }],
        'billing_info' => {
          'id' => order.billing_info.id,
          'address' => order.billing_info.address,
          'address_name' => order.billing_info.address_name,
          'city' => order.billing_info.city,
          'name' => order.billing_info.name,
          'phone' => order.billing_info.phone,
          'state' => order.billing_info.state,
          'dist' => order.billing_info.dist,
          'dist_code' => order.billing_info.dist_code,
          'province_id' => order.billing_info.province_id,
          'province' => order.billing_info.province_name,
          'province_name' => order.billing_info.province_name,
          'zip_code' => order.billing_info.zip_code,
          'country' => order.billing_info.country,
          'created_at' => order.billing_info.created_at.as_json,
          'updated_at' => order.billing_info.updated_at.as_json,
          'country_code' => order.billing_info.country_code,
          'shipping_way' => order.billing_info.shipping_way,
          'email' => order.billing_info.email
        },
        'shipping_info' => {
          'id' => order.shipping_info.id,
          'address' => order.shipping_info.address,
          'address_name' => order.shipping_info.address_name,
          'city' => order.shipping_info.city,
          'name' => order.shipping_info.name,
          'phone' => order.shipping_info.phone,
          'state' => order.shipping_info.state,
          'dist' => order.shipping_info.dist,
          'dist_code' => order.shipping_info.dist_code,
          'province_id' => order.shipping_info.province_id,
          'province' => order.shipping_info.province_name,
          'province_name' => order.shipping_info.province_name,
          'zip_code' => order.shipping_info.zip_code,
          'country' => order.shipping_info.country,
          'created_at' => order.shipping_info.created_at.as_json,
          'updated_at' => order.shipping_info.updated_at.as_json,
          'country_code' => order.shipping_info.country_code,
          'shipping_way' => order.shipping_info.shipping_way,
          'email' => order.shipping_info.email
        },
        'order_items' => order.order_items.map do |order_item|
          {
            'quantity' => order_item.quantity,
            'price' => order_item.price_in_currency(order_item.order.currency),
            'work_uuid' => order_item.itemable_uuid,
            'work_name' => order_item.itemable_name,
            'model_name' => order_item.itemable.product_name,
            'model_key' => order_item.itemable.product.key,
            'product_name' => order_item.itemable.product_name,
            'product_key' => order_item.itemable.product.key,
            'order_image' => order_item.itemable.order_image.thumb.url,
            'user_display_name' => order_item.itemable.user_display_name,
            'is_public' => order_item.itemable.is_public?
          }.merge JSON.parse(view.render('api/v3/unapproved_order_item', order_item: order_item))
        end
      )
    end
  end

  context 'with neweb/atm payment info' do
    let(:order) { create(:order, :with_atm) }
    let(:package) { double('Package', ship_code: '1234567', logistics_supplier_name: '圆通') }
    before do
      allow(order).to receive(:packages).and_return([package])
    end

    it 'renders order' do
      render 'api/v3/order', order: order
      expect(JSON.parse(rendered)).to eq(
        'uuid' => order.uuid,
        'price' => order.price,
        'currency' => order.currency,
        'status' => order.aasm_state.to_s,
        'status_i18n' => view.t("order.state.#{order.aasm_state}"),
        'payment' => order.payment,
        'payment_info' => order.payment_info.merge(
          'bank_id' => order.payment_object.bank_id,
          'bank_name' => order.payment_object.bank_name
        ),
        'coupon' => '',
        'order_price' => {
          'subtotal' => order.subtotal.as_json,
          'discount' => order.discount.as_json,
          'shipping_fee' => order.shipping_fee.as_json,
          'price' => order.price.as_json
        },
        'display_price' => {
          'subtotal' => view.render_price(order.subtotal, currency_code: order.currency),
          'discount' => view.render_price(order.discount, currency_code: order.currency),
          'shipping_fee' => view.render_price(order.shipping_fee, currency_code: order.currency),
          'price' => view.render_price(order.price, currency_code: order.currency)
        },
        'order_no' => order.order_no,
        'created_at' => order.created_at.as_json,
        'message' => order.message,
        'activities' => order.activities.where(key: %i(create paid shipped)).map do |activity|
          {
            'key' => activity.key,
            'created_at' => activity.created_at.as_json
          }
        end,
        'ship_code' => order.ship_code,
        'logistics_info' => [{ 'ship_code' => '1234567', 'logistics_supplier_name' => '圆通' }],
        'billing_info' => {
          'id' => order.billing_info.id,
          'address' => order.billing_info.address,
          'address_name' => order.billing_info.address_name,
          'city' => order.billing_info.city,
          'name' => order.billing_info.name,
          'phone' => order.billing_info.phone,
          'state' => order.billing_info.state,
          'dist' => order.billing_info.dist,
          'dist_code' => order.billing_info.dist_code,
          'province_id' => order.billing_info.province_id,
          'province' => order.billing_info.province_name,
          'province_name' => order.billing_info.province_name,
          'zip_code' => order.billing_info.zip_code,
          'country' => order.billing_info.country,
          'created_at' => order.billing_info.created_at.as_json,
          'updated_at' => order.billing_info.updated_at.as_json,
          'country_code' => order.billing_info.country_code,
          'shipping_way' => order.billing_info.shipping_way,
          'email' => order.billing_info.email
        },
        'shipping_info' => {
          'id' => order.shipping_info.id,
          'address' => order.shipping_info.address,
          'address_name' => order.shipping_info.address_name,
          'city' => order.shipping_info.city,
          'name' => order.shipping_info.name,
          'phone' => order.shipping_info.phone,
          'state' => order.shipping_info.state,
          'dist' => order.shipping_info.dist,
          'dist_code' => order.shipping_info.dist_code,
          'province_id' => order.shipping_info.province_id,
          'province' => order.shipping_info.province_name,
          'province_name' => order.shipping_info.province_name,
          'zip_code' => order.shipping_info.zip_code,
          'country' => order.shipping_info.country,
          'created_at' => order.shipping_info.created_at.as_json,
          'updated_at' => order.shipping_info.updated_at.as_json,
          'country_code' => order.shipping_info.country_code,
          'shipping_way' => order.shipping_info.shipping_way,
          'email' => order.shipping_info.email
        },
        'order_items' => order.order_items.map do |order_item|
          {
            'quantity' => order_item.quantity,
            'price' => order_item.price_in_currency(order_item.order.currency),
            'work_uuid' => order_item.itemable_uuid,
            'work_name' => order_item.itemable_name,
            'model_name' => order_item.itemable.product_name,
            'model_key' => order_item.itemable.product.key,
            'product_name' => order_item.itemable.product_name,
            'product_key' => order_item.itemable.product.key,
            'order_image' => order_item.itemable.order_image.thumb.url,
            'user_display_name' => order_item.itemable.user_display_name,
            'is_public' => order_item.itemable.is_public?
          }.merge JSON.parse(view.render('api/v3/unapproved_order_item', order_item: order_item))
        end
      )
    end
  end
end
