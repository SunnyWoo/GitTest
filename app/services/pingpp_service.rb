class PingppService
  def initialize(order)
    @order = order
  end

  def refund(refund_total, options = {})
    if refund_total.to_f == 0
      @order.errors.add(:base, "Refund total:#{refund_total} is error")
      return false
    end
    pingpp_refund_total = BigDecimal.new(refund_total.to_s) * 100
    note = note.present? ? options[:note] : note.blank?
    find_pingpp_charge
    return false unless @charge
    if pingpp_refund_total <= @charge.amount
      begin
        refund = @charge.refunds.create(amount: pingpp_refund_total.to_i,
                                        description: note)
        @order.begin_refund! if @order.price_after_refund == 0
        @order.begin_part_refund! if @order.price_after_refund > 0
        if refund.status == 'pending' && @order.pingpp_alipay_payment?
          @order.errors.add(:failure_msg, error_msg(refund.failure_msg))
        end
        return true
      rescue Pingpp::InvalidRequestError => e
        @order.errors.add(:base, error_msg(e.message))
      end
    else
      @order.errors.add(:base, 'Refund total is more then order total.')
    end
    false
  end

  def self.refund_success(order, refund_no, amount, note)
    return if order.refunds.find_by_refund_no(refund_no).present?
    order.refunds.create(refund_no: refund_no,
                         amount: amount,
                         note: note)
    order.refund! if order.price_after_refund == 0
    order.part_refund! if order.price_after_refund > 0
  end

  private

  def error_msg(pingpp_error)
    pingpp_error
  end

  def find_pingpp_charge
    @charge = Pingpp::Charge.retrieve(@order.payment_id)
  rescue
    @order.errors.add(:base, "Can't find pingpp payment.")
    Rails.logger.error "Pingpp payment not found with payment id #{@payment_id}"
  end
end
