class CouponCheckService
  attr_reader :coupon, :user, :order

  def initialize(coupon, user: nil, order: nil)
    @coupon = coupon
    @user = user
    @order = order
  end

  def pass?
    if !coupon.is_enabled?
      coupon.errors.add(:base, 'Code is disable')
      false
    elsif coupon.out_of_range?
      coupon.errors.add(:base, 'Code is expired')
      false
    elsif reach_limit?
      coupon.errors.add(:base, 'Code is used')
      false
    elsif forbidden_scope?
      coupon.errors.add(:base, 'Code is forbidden')
      false
    else
      true
    end
  end

  def pass_with_redeem_work?(gid_param)
    return false unless coupon.condition.in? %w(simple rules)
    rule_work_gids = coupon.root_coupon_rules.first.work_gids
    work = GlobalID::Locator.locate gid_param
    work.try(:redeem?).to_b && rule_work_gids.include?(gid_param) && pass?
  end

  def pass_with_bdevent?(tmp_bdevent_id)
    return false unless coupon.condition.in? %w(simple rules)
    rule_bdevent = coupon.root_coupon_rules.first.bdevent
    rule_bdevent.try(:available?) && rule_bdevent.id == tmp_bdevent_id.to_i && pass?
  end

  def pass_with_product?(product_id)
    return false unless coupon.condition.in? %w(simple rules)
    rule_product_model_ids = coupon.root_coupon_rules.first.product_model_ids
    rule_product_model_ids.include?(product_id) && pass?
  end

  def reach_limit?
    coupon.reach_limit? || reach_limit_by_user?
  end

  # 單一用户優惠次數
  # order: 兑换商品存储订单后会再次验证coupon code
  # user不存在并且coupon有单一用户使用次数限制时不允许使用coupon
  def reach_limit_by_user?
    return true if user.blank? && coupon.user_usage_count_limit != -1
    user_usage_count = (user.orders.where(coupon_id: coupon.id) - [order]).count if user.present?
    coupon.user_usage_count_limit != -1 && (user_usage_count.to_i >= coupon.user_usage_count_limit)
    # 因為二次付款延期先pending
    # return false if user.blank? && coupon.user_usage_count_limit == -1
    # paid_orders_with_the_coupon = user.paid_orders_with_coupon(id)
    # delayed_orders_with_the_coupon = user.delayed_orders_with_coupon(id)
    # user_usage_count = (paid_orders_with_the_coupon + delayed_orders_with_the_coupon - [order]).count
    # coupon.user_usage_count_limit != -1 && (user_usage_count.to_i >= user_usage_count_limit)
  end

  def forbidden_scope?
    return false unless order.is_a?(Order) # No Order Information, unable to make judgement
    root_coupon = coupon.root? ? coupon : coupon.parent
    CouponForbiddenEvent.active.any? { |e| e.blocking?(root_coupon, order, user) }
  end
end
