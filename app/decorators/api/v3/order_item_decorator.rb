class Api::V3::OrderItemDecorator < ApplicationDecorator
  delegate_all
  delegate :currency, to: :order

  decorates_association :itemable, with: Pricing::ItemableDecorator

  class << self
    def model_name
      OrderItem.model_name
    end

    def spread_by_coupon_discount(item)
      coupon_discount = item.adjustments.detect(&:discount?)

      discount_quantity = if item.original_prices == item.prices
                            0
                          elsif coupon_discount.try(:original?)
                            coupon_discount.quantity
                          else
                            0
                          end

      normal_quantity = item.quantity - discount_quantity

      items = []

      if normal_quantity > 0
        item = ActiveType.cast(item, OrderItem::ForPricing)
        item.quantity = normal_quantity
        items << new(item)
      end

      if discount_quantity > 0
        item = ActiveType.cast(item, OrderItem::ForPricing)
        item.quantity = discount_quantity
        item.coupon_discount = coupon_discount
        items << new(item)
      end

      items
    end
  end

  def initialize(item)
    item = ActiveType.cast(item, OrderItem::ForPricing) unless item.is_a?(OrderItem::ForPricing)
    super(item)
  end

  def selling_price
    @selling_price ||= begin
                         if adjustments_value.zero?
                           base_price
                         else
                           value = base_price.value + adjustments_value
                           Price.build_by_value(value, currency)
                         end
                       end
  end

  def price_in_currency(target_currency)
    selling_price[target_currency]
  end

  def subtotal
    selling_price.value * quantity
  end

  private

  def base_price
    @base_price ||= base_price_type == 'original' ? original_prices : special_prices
  end

  def adjustments_value
    source.adjustments_value(base_price_type)
  end

  def original_prices
    @original_prices ||= Price.new(source.original_prices || itemable.original_prices || 0, currency)
  end

  def special_prices
    @special_prices ||= Price.new(source.prices || itemable.prices || 0, currency)
  end

  def base_price_type
    coupon_discount ? coupon_discount.source.base_price_type : order.base_price_type
  end
end
