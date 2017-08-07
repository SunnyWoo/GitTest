class Payment::Redeem < Payment
  attr_reader :error_messages, :order

  def initialize(*)
    @error_messages = []
    super
  end

  def pay
    order.logcraft_extra_info = to_hash
    if valid?
      order.price = 0
      order.discount = 0
      order.pay!
      order.coupon.increment!(:usage_count)
      order.coupon.parent.increment!(:usage_count) if order.coupon.parent.present?
      order.create_activity(:redeem)
      true
    else
      order.errors.add(:base, error_messages.flatten.split(', '))
      order.create_activity(:redeem_fail, error_messages: error_messages.flatten.split(', '))
      false
    end
  end

  protected

  def valid?
    itemable = order.order_items.first.itemable
    case
    when order.order_items.size > 1
      fail PaymentRedeemError, '兌換商品數量大於一'
    when order.order_items.blank?
      fail PaymentRedeemError, '沒有兌換商品'
    when order.coupon.blank?
      fail PaymentRedeemError, '沒有兌換碼'
    when order.bdevent_id.blank? && order.coupon.can_use_with_redeem_work?(itemable.to_gid_param, order.user, order) == false
      fail PaymentRedeemError, 'OrderItem 無法被兌換'
    when order.bdevent_id.present? && order.coupon.can_use_with_bdevent?(order.bdevent_id, order.user, order) == false
      fail PaymentRedeemError, 'Order 無法被兌換'
    end
    @error_messages.blank?
  rescue PaymentRedeemError => e
    @error_messages << e.message
    @error_messages.blank?
  end
end
