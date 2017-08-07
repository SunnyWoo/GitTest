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

# NOTE: not used in v3 api, remove me later
class OrderSerializer < ActiveModel::Serializer
  attributes :uuid, :price, :currency, :status, :coupon, :order_no,
             :order_price, :order_images, :payment, :payment_info
  attribute :created_at, key: :create_time

  has_many :order_items
  has_one :billing_info, serializer: BillingProfileSerializer
  has_one :shipping_info, serializer: BillingProfileSerializer

  def status
    I18n.t("order.state.#{object.aasm_state}")
  end

  def coupon
    if object.coupon.present?
      object.coupon.code
    end
  end

  def order_price
    {
      sub_total: object.order_items_total,
      coupon: object.coupon_price,
      shipping_fee: object.shipping_price,
      total: object.price
    }
  end

  def order_images
    object.order_items.map do |order_item|
      { image_url: order_item.itemable.order_image.thumb.url }
    end
  end

  def payment_info
    case object.payment
    when 'neweb/atm'
      object.payment_info.merge(bank_id: object.payment_object.bank_id)
    else
      object.payment_info
    end
  end
end
