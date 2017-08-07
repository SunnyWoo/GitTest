class Promotion::Rule::IncludeFreeShippingCoupon
  # coupon不可與其他 promotion 同時使用时
  # 免运coupon活动可用(目前只有这一个例外)
  def conformed_by_order?(order)
    order.coupon && order.coupon.free_shipping?
  end
end
