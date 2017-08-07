class Pricing::StoreOrderPriceCalculator < Pricing::OrderPriceCalculator
  def process!
    build_item_adjustment_by_coupon if mutable?

    @items_total = calculate_items_total

    build_order_adjustment_by_coupon if mutable?

    @order_discount = calculate_order_discount
    @subtotal = @items_total - @order_discount
    @shipping_fee = calculate_shipping_fee

    order.shipping_fee = @shipping_fee.fetch(order_currency)

    @shipping_fee_discount = calculate_shipping_fee_discount

    @total_discount = [@order_discount, @items_total].min
    @total_amount = @items_total + @shipping_fee - @shipping_fee_discount - @total_discount

    @processed = true

    OpenStruct.new(
      subtotal: subtotal,
      shipping: shipping,
      discount: actual_discount,
      shipping_fee_discount: actual_shipping_fee_discount,
      price: actual_price
    )
  end

  def calculate_items_total
    return Price.new(0, base_currency) if order.order_items.empty?

    subtotal = order_items.map do |item|
      item.prices[base_currency] * item.quantity
    end.sum

    Price.new(subtotal, base_currency)
  end
end
