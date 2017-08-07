class Admin::MarketingReport::OrderItemDecorator < ApplicationDecorator
  decorates OrderItem

  delegate_all

  delegate :order_no, :created_at, :paid_at, :platform, :currency, :embedded_coupon, to: :order, prefix: true
  delegate :product_key, :name, to: :itemable, prefix: true

  def special_price_profit
    (original_price - price)
  end

  def actual_total_amount
    (quantity * price.to_i) - discount.to_i
  end

  def original_price
    original_price_in_currency(order_currency)
  end

  def price
    price_in_currency(order_currency)
  end

  def order_embedded_coupon_code
    order_embedded_coupon.try(:code)
  end

  def itemable_user_display_name
    itemable.user.display_name
  end
end
