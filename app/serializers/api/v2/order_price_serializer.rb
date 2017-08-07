# NOTE: only used in v2 api, remove me later
class Api::V2::OrderPriceSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  attributes :currency, :coupon, :price, :display_price

  def coupon
    object.coupon.try(:code) || ''
  end

  def price
    {
      subtotal: object.subtotal,
      discount: object.discount,
      shipping_fee: object.shipping_fee,
      price: object.price
    }
  end

  def display_price
    {
      subtotal: render_price(object.subtotal, currency_code: object.currency),
      discount: render_price(object.discount, currency_code: object.currency),
      shipping_fee: render_price(object.shipping_fee, currency_code: object.currency),
      price: render_price(object.price, currency_code: object.currency)
    }
  end
end
