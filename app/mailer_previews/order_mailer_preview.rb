class OrderMailerPreview
  def receipt
    OrderMailer.receipt user_id, order_id, I18n.locale
  end

  def receipt_with_status
    OrderMailer.receipt_with_status user_id, order_id, I18n.locale
  end

  def download
    OrderMailer.download user_id, order_id, I18n.locale
  end

  def ship
    OrderMailer.ship user_id, order_id, I18n.locale
  end

  def conflict_warning
    OrderMailer.conflict_warning order_id, I18n.locale
  end

  def store_receipt
    order = Order.shop.last
    OrderMailer.store_receipt order.user.id, order.id, I18n.locale
  end

  private

  def user_id
    User.last.id
  end

  def order_id
    Order.last.id
  end
end
