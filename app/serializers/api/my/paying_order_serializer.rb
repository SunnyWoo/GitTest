# NOTE: only used in v1 api, remove me later
class Api::My::PayingOrderSerializer < ActiveModel::Serializer
  attributes :uuid, :status, :payment, :order_no, :payment_info

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

  def payment_info
    object.payment_object
  end
end
