# == Schema Information
#
# Table name: orders
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  aasm_state            :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  price                 :float
#  currency              :string(255)
#  payment_id            :string(255)
#  order_no              :string(255)
#  work_state            :integer          default(0)
#  refund_id             :string(255)
#  ship_code             :string(255)
#  uuid                  :string(255)
#  coupon_id             :integer
#  payment               :string(255)
#  order_data            :hstore
#  payment_info          :json             default({})
#  approved              :boolean          default(FALSE)
#  invoice_state         :integer          default(0)
#  invoice_info          :json
#  embedded_coupon       :json
#  subtotal              :decimal(8, 2)
#  discount              :decimal(8, 2)
#  shipping_fee          :decimal(8, 2)
#  shipping_receipt      :string(255)
#  application_id        :integer
#  message               :text
#  shipped_at            :datetime
#  viewable              :boolean          default(TRUE)
#  paid_at               :datetime
#  remote_id             :integer
#  delivered_at          :datetime
#  deliver_complete      :boolean          default(FALSE)
#  remote_info           :json
#  approved_at           :datetime
#  merge_target_ids      :integer          default([]), is an Array
#  packaging_state       :integer          default(0)
#  shipping_state        :integer          default(0)
#  shipping_fee_discount :decimal(8, 2)    default(0.0)
#  flags                 :integer
#  watching              :boolean          default(FALSE)
#  invoice_required      :boolean
#  checked_out_at        :datetime
#  lock_version          :integer          default(0), not null
#  enable_schedule       :boolean          default(TRUE)
#  source                :integer          default(0), not null
#  channel               :string(255)
#  order_info            :json
#

require 'spec_helper'

describe OrderSerializer do
  it 'works' do
    order = create(:order)
    order.reload
    json = JSON.parse(OrderSerializer.new(order).to_json)
    expect(json).to eq(
      'order' => {
        'uuid' => order.uuid,
        'price' => order.price,
        'currency' => order.currency,
        'status' => I18n.t("order.state.#{order.aasm_state}"),
        'coupon' => nil,
        'order_no' => order.order_no,
        'order_price' => {
          'sub_total' => order.order_items_total,
          'coupon' => order.coupon_price,
          'shipping_fee' => order.shipping_price,
          'total' => order.price
        },
        'order_images' => order.order_items.map do |item|
          { 'image_url' => item.itemable.order_image.thumb.url }
        end,
        'payment' => 'paypal',
        'payment_info' => { 'method' => 'paypal' },
        'create_time' => order.created_at.as_json,
        'order_items' => order.order_items.map do |item|
          {
            'quantity' => item.quantity,
            'work_id' => item.itemable.uuid,
            'work_uuid' => item.itemable.uuid,
            'price' => item.price_in_currency(order.currency)
          }
        end,
        'billing_info' => {
          'address' => order.billing_info.address,
          'city' => order.billing_info.city,
          'name' => order.billing_info.name,
          'phone' => order.billing_info.phone,
          'state' => order.billing_info.state,
          'zip_code' => order.billing_info.zip_code,
          'country' => order.billing_info.country,
          'created_at' => order.billing_info.created_at.as_json,
          'updated_at' => order.billing_info.updated_at.as_json,
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
          'created_at' => order.shipping_info.created_at.as_json,
          'updated_at' => order.shipping_info.updated_at.as_json,
          'country_code' => order.shipping_info.country_code,
          'shipping_way' => order.shipping_info.shipping_way,
          'email' => order.shipping_info.email
        }
      }
    )
  end
end
