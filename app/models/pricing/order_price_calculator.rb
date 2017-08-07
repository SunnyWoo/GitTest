class Pricing::OrderPriceCalculator
  include ActsAsAdjustmentBuilder

  attr_reader :order, :base_currency

  delegate :order_items, to: :order

  def initialize(order, currency = nil)
    @order = order
    @base_currency = currency || order_currency
    @processed = false
  end

  def mutable?
    order.pending? && !order.locked?
  end

  def process!
    if mutable?
      purge_coupon_adjustments_if_necessary
      build_item_adjustment_by_promotion
      build_item_adjustment_by_coupon
    end

    # Calculate items total firstly,
    # It was depended when building order/shipping fee adjustment
    @items_total = calculate_items_total

    build_order_adjustment_by_promotion if mutable?
    build_order_adjustment_by_coupon if mutable?

    @order_discount = calculate_order_discount
    @subtotal = @items_total - @order_discount
    @shipping_fee = calculate_shipping_fee

    # Write the shipping fee to order
    # It based on Order#shipping_fee to judge adjustment of free shipping
    order.shipping_fee = @shipping_fee.fetch(order_currency)

    build_shipping_fee_adjustment_by_promotion if mutable?

    @shipping_fee_discount = calculate_shipping_fee_discount

    @total_discount = [@order_discount, @items_total].min
    @total_amount = @items_total + @shipping_fee - @shipping_fee_discount - @total_discount

    @processed = true

    OpenStruct.new(
      subtotal: subtotal,
      shipping: shipping,
      discount: actual_discount,
      shipping_fee_discount: actual_shipping_fee_discount,
      price_without_shipping_fee: actual_price_without_shipping_fee,
      price: actual_price
    )
  end

  def process
    process!
  end

  %w(items_total shipping_fee total_discount total_amount shipping_fee_discount).each do |key|
    class_eval <<-RUBY
      def #{key}(target_currency = nil)
        target_currency ||= base_currency
        processed do
          price = @#{key}.dup.with_currency!(target_currency)
          floored_value(@#{key}, target_currency)
        end
      end
    RUBY
  end

  # Legacy interfaces
  alias_method :subtotal, :items_total
  alias_method :shipping, :shipping_fee
  alias_method :price, :total_amount

  def discount(target_currency = nil)
    target_currency ||= base_currency
    processed do
      normalize @total_discount.fetch(target_currency)
    end
  end

  def actual_discount(currency = nil)
    currency ||= base_currency
    processed do
      ceiled_value @total_discount, currency
    end
  end

  def actual_price(currency = nil)
    currency ||= base_currency
    value = items_total(currency) +
            shipping_fee(currency) -
            actual_discount(currency) -
            actual_shipping_fee_discount(currency)

    price = Price.new(value, currency)
    floored_value(price, currency)
  end

  def actual_price_without_shipping_fee(currency = nil)
    currency ||= base_currency
    value = items_total(currency) - actual_discount(currency)
    price = Price.new(value, currency)

    floored_value(price, currency)
  end

  def actual_shipping_fee_discount(currency = nil)
    currency ||= base_currency
    ceiled_value(@shipping_fee_discount, currency)
  end

  def refund(currency = nil)
    currency ||= base_currency
    floored_value(refund_price, currency)
  end

  def refund_price
    value = order.refunds.to_a.sum(&:amount)
    Price.new(value, order_currency)
  end

  def price_after_refund(target_currency = nil)
    target_currency ||= base_currency
    processed do
      value = actual_price(target_currency) - refund(target_currency)
      price = Price.new(value, target_currency)
      floored_value(price, target_currency)
    end
  end

  private

  def processed
    process! unless @processed
    yield
  end

  def order_items
    @order_items ||= order.order_items.to_a
  end

  def coupon
    order.coupon
  end

  def build_item_adjustment_by_promotion
    unless order.commandp?
      order.order_items.each(&:store_prices)
      return false
    end

    order.order_items.each do |item|
      next unless item.itemable.respond_to?(:build_promotion_adjustment)
      item.itemable.build_promotion_adjustment(item) unless coupon.try(:is_not_include_promotion?)
      item.store_prices
    end
  end

  def build_item_adjustment_by_coupon
    return unless coupon_affecting_items?
    Pricing::CouponItemAdjustmentBuilder.new(order).perform
  end

  def build_order_adjustment_by_promotion
    return false unless order.commandp?
    return false if coupon.try(:is_not_include_promotion?)
    purge_promotion_order_adjustments_if_necessary

    applicabel_promotions = Promotion.available.order_level
    applicabel_promotions.each do |promotion|
      promotion.build_apply_adjustment(order) if promotion.applicable?(order)
    end
  end

  def build_order_adjustment_by_coupon
    return unless coupon
    return if coupon.affecting_item?
    return unless coupon.order_rules.all? { |r| r.conformed_by_order?(order) }

    items_total_price = @items_total.dup
    value = coupon.discount_formula.difference!(items_total_price, order_currency) * -1

    build_adjustment(order, order, coupon, :apply, value, 1)
  end

  def build_shipping_fee_adjustment_by_promotion
    return false unless order.commandp?
    purge_free_shipping_adjustments_if_necessary
    return unless @shipping_fee > Price.new(0)
    promotion = available_shipping_fee_promotion
    promotion.build_apply_adjustment(order) if promotion
  end

  def coupon_affecting_items?
    return false unless coupon && coupon.affecting_item?
    return false if coupon.item_rules.empty?
    return false if coupon.order_rules.any? { |r| !r.conformed_by_order?(order) }

    true
  end

  def calculate_items_total
    return Price.new(0, base_currency) if order.order_items.empty?

    subtotal = order_items.map do |item|
      item.prices[base_currency] * item.quantity
    end.sum

    adjustment_value = order.temp_item_adjustments_by_promotion.sum(&:value)

    Price.new(subtotal, base_currency) + Price.new(adjustment_value, order_currency)
  end

  def calculate_order_discount
    adjustments = (order.adjustments + order.order_adjustments).uniq

    # Write order_item#discount back
    unless order_items.empty?
      order_items.each { |i| i.discount = 0 }

      adjustments.select(&:item_level?).each do |adj|
        item = order_items.detect { |x| x == adj.adjustable }
        item.discount += adj.value * -1
      end

      items_total_value = @items_total.to_f

      adjustments.select(&:order_level?).each do |adj|
        last_item = order_items[-1]
        discount = total_discount = adj.value * -1
        order_items[0..-2].each do |item|
          ratio = item.subtotal.to_f / items_total_value
          value = (total_discount * ratio)
          item.discount += normalize(value, &:floor)
          discount -= item.discount
        end
        last_item.discount = discount
      end
    end

    value = adjustments.reject(&:pricing?)
                       .reject(&:for_shipping_fee?).sum(&:value) * -1
    Price.new(value, order_currency)
  end

  def calculate_shipping_fee_discount
    return Price.new(0, base_currency) if @shipping_fee.nil?
    value = order.order_adjustments.select(&:for_shipping_fee?).sum(&:value) * -1
    value = Price.new(value, order_currency).with_currency!(base_currency)
    [value, @shipping_fee].min
  end

  def calculate_shipping_fee
    value = if SiteSetting.enabled?('ShippingFeeSwitch')
              ShippingFeeService.new(order).price
            else
              Fee.find_by(name: order.shipping_info_shipping_way.to_s)
                 .try(:price_in_currency, order_currency) || 0
            end

    Price.new(value, order_currency)
  end

  def available_shipping_fee_promotion
    Promotion.started.shipping_fee.sort.detect { |p| p.applicable?(order) }
  end

  def purge_coupon_adjustments_if_necessary
    return if order.new_record?
    order.adjustments.select(&:discount?).each do |adj|
      next if adj.reverted?
      order.adjustments.delete(adj) if adj.source != order.coupon
    end
    true
  end

  def purge_promotion_order_adjustments_if_necessary
    return if order.new_record?
    order.order_adjustments.select { |a| a.order_level? && !a.discount? }.each do |adj|
      next if adj.reverted?
      order.order_adjustments.delete(adj) unless adj.source.applicable?(order)
    end
    true
  end

  def purge_free_shipping_adjustments_if_necessary
    return if order.new_record?
    order.order_adjustments.select(&:for_shipping_fee?).each do |adj|
      next if adj.reverted?
      order.order_adjustments.delete(adj) unless adj.source.applicable?(order)
    end
    true
  end

  def ceiled_value(price, currency = nil)
    processed_value(price, currency, :ceil)
  end

  def floored_value(price, currency = nil)
    processed_value(price, currency, :floor)
  end

  def processed_value(price, currency, method)
    return nil if price.nil?
    currency ||= base_currency
    value = price.fetch(currency)
    normalize(value, &method.to_sym)
  end

  def normalize(value, currency = nil, &block)
    currency ||= base_currency
    [Price.normalize(value, currency, &block), 0].max
  end

  def order_currency
    order.currency || Region.default_currency
  end
end
