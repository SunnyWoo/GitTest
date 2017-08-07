# DEPRECATED: remove me when things done
class CartIndexSerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  include CartHelper

  attributes :price,
             :subtotal,
             :shipping_fee,
             :discount,
             :coupon_code,
             :order_item_quantity_total,
             :payment,
             :payment_path,
             :shipping_info_shipping_way,
             :order_items,
             :currency

  has_one :billing_info, serializer: BillingProfileSerializer
  has_one :shipping_info, serializer: BillingProfileSerializer

  def price
    render_price(object.price, currency_code: object.currency)
  end

  def subtotal
    render_price(object.subtotal, currency_code: object.currency)
  end

  def shipping_fee
    render_price(object.shipping_price, currency_code: object.currency)
  end

  def discount
    render_price(object.discount, currency_code: object.currency)
  end

  def coupon_code
    object.embedded_coupon ? object.embedded_coupon.code : nil
  end

  def order_item_quantity_total
    object.order_items.inject(0) { |sum, oi| sum + oi.quantity }
  end

  def order_items
    object.order_items.map do |order_item|
      {
        uuid: order_item.itemable.uuid,
        name: order_item.itemable.name,
        model_name: order_item.itemable.product_name,
        order_image: order_item.itemable.order_image.url,
        order_image_thumb: order_item.itemable.order_image.thumb.url,
        quantity: order_item.quantity,
        price: order_item.itemable.price_in_currency(object.currency),
        subtotal: render_price(order_item.price_in_currency(object.currency) * order_item.quantity,
                               currency_code: object.currency),
        del_path: cart_path(order_item.itemable.uuid)
      }
    end
  end

  def payment_path
    begin_payment_path(object.payment_method)
  end
end
