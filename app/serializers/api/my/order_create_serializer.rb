# NOTE: only used in v1 api, remove me later
class Api::My::OrderCreateSerializer < ActiveModel::Serializer
  attributes :uuid, :price, :currency, :status, :payment, :payment_method,
             :coupon, :order_no, :order_price

  has_many :order_items
  has_one :billing_info, serializer: BillingProfileSerializer
  has_one :shipping_info, serializer: BillingProfileSerializer

  def status
    object.aasm_state
  end

  def order_price
    {
      sub_total: object.order_items_total,
      coupon: object.coupon_price,
      shipping_fee: object.shipping_price,
      total: object.price,
    }
  end
end
