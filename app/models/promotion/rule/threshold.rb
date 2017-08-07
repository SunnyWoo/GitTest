class Promotion::Rule::Threshold
  def initialize(theshold_price, *_args)
    @price = theshold_price
  end

  # 计算订单的金额需要减去coupon折扣的费用
  # coupon不可與其他 promotion 同時使用时活动不可以用
  # theshold_price是Price类型的
  def conformed_by_order?(order)
    return false if order.embedded_coupon.try(:is_not_include_promotion)
    theshold_price = @price[order.currency].to_f
    if order.coupon.present?
      order.order_items.map { |item| item.subtotal - Price.new(item.discount.to_f, order.currency) }.sum.to_f >= theshold_price
    else
      order.order_items.map(&:subtotal).sum.to_f >= theshold_price
    end
  end
end
