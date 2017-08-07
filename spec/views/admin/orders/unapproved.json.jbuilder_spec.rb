require 'spec_helper'

RSpec.describe 'admin/orders/unapproved.json.jbuilder', :caching, type: :view do
  let!(:order) { create(:order).tap(&:reload) }
  let(:orders) { Order.page(1).decorate(with: Admin::OrderDecorator) }

  it 'renders order' do
    assign(:orders, orders)
    render
    expect(JSON.parse(rendered)).to eq(
      'orders' => [{
        'id' => order.id,
        'order_no' => order.order_no,
        'remote_order_no' => order.remote_info['order_no'],
        'created_at' => order.created_at.as_json,
        'platform' => order.platform,
        'user_agent' => order.user_agent,
        'shipping_info_shipping_way' => order.shipping_info_shipping_way,
        'links' => {
          'show' => view.url_for([:admin, order, locale: I18n.locale]),
          'approve' => view.url_for([:admin, order, :approve, locale: I18n.locale]),
          'create_note' => view.admin_noteable_notes_path(order)
        },
        'order_price' => {
          'subtotal' => order.subtotal.as_json,
          'discount' => order.discount.as_json,
          'shipping_fee' => order.shipping_fee.as_json,
          'price' => order.price.as_json,
          'price_in_currency' => view.render_price(order.price, currency_code: order.currency)
        },
        'coupon_code' => order.coupon.try(:code),
        'message' => order.message,
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
            'name' => order_item.itemable.name,
            'links' => { 'edit' => view.url_for([:edit, :admin, order_item.itemable, locale: I18n.locale]),
                         'create_note' => view.admin_noteable_notes_path(order_item) },
            'images' => {
              'order_image' => { 'thumb' => order_item.itemable_order_image.thumb.url,
                                 'origin' => order_item.itemable_order_image.url },
              'cover_image' => { 'thumb' => order_item.itemable_cover_image.thumb.url,
                                 'origin' => order_item.itemable_cover_image.url },
              'print_image' => { 'thumb' => order_item.itemable_print_image.thumb.url,
                                 'origin' => order_item.itemable_print_image.url }
            },
            'notes' => order_item.notes.map do |note|
              {
                'id' => note.id,
                'message' => note.message,
                'created_at' => note.created_at.as_json,
                'user_email' => note.user_email,
                'links' => {
                  'update' => view.polymorphic_path([:admin, note.noteable, note], locale: I18n.locale)
                }
              }
            end,
            'user_display_name' => order_item.itemable.user_display_name,
            'is_public' => order_item.itemable.is_public?
          }
        end,
        'notes' => order.notes.map do |note|
          {
            'id' => note.id,
            'message' => note.message,
            'created_at' => note.created_at.as_json,
            'user_email' => note.user_email,
            'links' => {
              'update' => view.polymorphic_path([:admin, note.noteable, note], locale: I18n.locale)
            }
          }
        end,
        'tags' => []
      }],
      'meta' => {
        'pagination' => {
          'current_page' => orders.current_page,
          'next_page' => orders.next_page,
          'previous_page' => orders.previous_page,
          'total_entries' => orders.total_entries,
          'total_pages' => orders.total_pages
        }
      }
    )
  end
end
