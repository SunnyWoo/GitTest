class PriceCalculator
  attr_reader :order, :default_currency

  def initialize(order, default_currency = nil)
    @order = order
    @default_currency = default_currency || order.currency
  end

  # 小計
  # 使用coupon时按coupon计算
  # 没有使用coupon计算item.price_in_currency
  def subtotal(target_currency = default_currency)
    if order.embedded_coupon
      value = order.embedded_coupon.base_price(self, default_currency)
    else
      value = order.order_items.map do |item|
        item.adjusted_subtotal(default_currency)
      end.sum
      value = 0 if value < 0
    end
    value = to_target_currency(value, target_currency)
    floored_value(value, target_currency)
  end

  # 運費
  def shipping(target_currency = default_currency)
    value = if SiteSetting.enabled?('ShippingFeeSwitch') && shipping_fee_service_start_at
              ShippingFeeService.new(order).price
            else
              Fee.find_by(name: order.shipping_info_shipping_way.to_s)
                 .try(:price_in_currency, default_currency) || 0
            end
    to_target_currency(value, target_currency) unless value.nil?
  end

  # 運費開始時間修正
  # https://app.asana.com/0/9672537926113/146348745320004
  def shipping_fee_service_start_at
    return true unless order.created_at
    start_at = Region.china? ? '2016/06/20 19:00' : '2016/06/20 18:00'
    order.created_at >= Time.zone.parse(start_at)
  end

  # 折價
  def discount(target_currency = default_currency)
    return  0 if subtotal.zero?
    value = 0
    value += order.embedded_coupon.discount(self, default_currency) if order.embedded_coupon
    value += order_adjustments_value * -1
    to_target_currency(value, target_currency)
  end

  def actual_discount(target_currency = default_currency)
    ceiled_value(discount(target_currency), target_currency)
  end

  def shipping_fee_discount(target_currency = default_currency)
    shipping_fee = shipping(target_currency)
    return 0 if shipping_fee.nil?
    value = order.order_adjustments.select(&:for_shipping_fee?).sum(&:value) * -1
    [value, shipping_fee].min
  end

  def actual_shipping_fee_discount(target_currency = default_currency)
    ceiled_value(shipping_fee_discount(target_currency), target_currency)
  end

  # 總價
  def price(target_currency = default_currency)
    value = subtotal + shipping.to_f - discount - shipping_fee_discount
    value = to_target_currency(value, target_currency)
    floored_value(value, target_currency)
  end

  def actual_price(target_currency = default_currency)
    value = subtotal + shipping.to_f - actual_discount - actual_shipping_fee_discount
    floored_value(to_target_currency(value, target_currency), target_currency)
  end

  # 退費
  def refund(target_currency = default_currency)
    value = order.refunds.map(&:amount).reduce(:+) || 0
    if order.currency != default_currency
      refunds = order.refunds.map do |refund|
        refund.to_target_currency_amount(default_currency)
      end
      value = refunds.reduce(:+) || 0
    end
    to_target_currency(value, target_currency)
  end

  # 扣掉退款的 Price
  def price_after_refund(target_currency = default_currency)
    value = actual_price - refund
    value = to_target_currency(value, target_currency)
    floored_value(value, target_currency)
  end

  # 对运费的折扣不能计算到subtotal
  def order_adjustments_value(_base_price_type = 'special')
    order.order_adjustments.select do |adj|
      adj.order_level? && !adj.source.is_a?(Coupon)
    end.sum(&:value).to_f
  end

  private

  def to_target_currency(value, target_currency)
    return value if target_currency == default_currency
    target_currency_type ||= CurrencyType.find_by!(code: target_currency)
    value * default_currency_type.rate / target_currency_type.rate
  end

  def ceiled_value(value, currency)
    processed_value(value, currency, :ceil)
  end

  def floored_value(value, currency)
    processed_value(value, currency, :floor)
  end

  def processed_value(value, currency, method)
    rate = case currency
           when 'TWD', 'JPY' then 1.0
           else 100.0
           end
    # round(4) 是為了防止某些浮點數計算誤差 如 9.27 - 1.86 = 7.40999999999 (實為 7.41)
    (value * rate).round(4).send(method) / rate
  end

  def default_currency_type
    @default_currency_type ||= CurrencyType.find_by!(code: default_currency)
  end
end
