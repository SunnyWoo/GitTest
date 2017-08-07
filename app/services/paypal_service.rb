require 'paypal-sdk-rest'
include PayPal::SDK::Core::Logging

class PaypalService
  def initialize(order, params = {})
    @order = order
    @payment_id = params[:payment_id]
  end

  def verify_with_paypal
    check_pay_zero = @order.check_pay_zero(@payment_id)
    if @payment_id == '0' && check_pay_zero
      return true
    elsif @payment_id == '0' || @payment_id.nil?
      @order.errors.add(:base, 'Payment id can\'t be 0 or null')
      return false
    end

    if payment = find_paypal_payment
      if payment.state == 'approved'
        amount = payment.transactions.first.amount
        if amount.total.to_f >= @order.price
          if amount.currency == @order.currency
            @order.update_attribute(:payment_id, @payment_id)
            @order.pay!
            return true
          else
            @order.errors.add(:base, "Currency in payment is #{amount.currency} but this order was #{@order.currency}")
            return false
          end
        else
          @order.errors.add(:base, "Order price in payment is #{amount.total.to_f} but this order was #{@order.price}")
          return false
        end
      else
        @order.errors.add(:base, "Payment state is #{payment.state}, you must give an approved payment to continue.")
        return false
      end
    else
      return false
    end
  end

  def approved?
    if @payment_id == '0' || @payment_id.nil?
      return false
    end

    if payment = find_paypal_payment
      payment.state == 'approved'
    else
      return false
    end
  end

  def create_payment_sale(payment_attributes)
    payment_attributes = payment_attributes.merge(build_transaction)
    payment = PayPal::SDK::REST::Payment.new(payment_attributes)

    begin
      res = payment.create
      if payment.error.nil?
        @order.update_attributes(payment_id: payment.id)
        return true
      else
        @order.errors.add(:base, error_msg(payment.error))
        return false
      end
    rescue
      @order.errors.add(:base, "create payment error.")
    end
  end

  def refund(refund_total, options = {})
    note = options[:note]
    begin
      payment = PayPal::SDK::REST::Payment.find(@order.payment_id)
    rescue
      @order.errors.add(:base, "Refund error.")
    end
    if refund_total == 0
      @order.errors.add(:base, "Refund total:#{refund_total} is error")
      return false
    end

    if payment
      sale = payment.transactions.first.related_resources.first.sale
      if sale
        if refund_total.present? && refund_total.to_f <= sale.amount.total.to_f
          refund = sale.refund(amount: { total: refund_total,
                                         currency: @order.currency })
          if refund.error.nil?
            @order.refunds.create(refund_no: refund.id, amount: refund_total, note: note)
            @order.refund! if @order.price_after_refund == 0
            @order.part_refund! if @order.price_after_refund > 0
            return true
          else
            @order.errors.add(:base, error_msg(refund.error))
            return false
          end
        else
          @order.errors.add(:base, 'Refund total is more then order total.')
          return false
        end
      else
        @order.errors.add(:base, 'Can\'t find Paypal payment sale.')
        return false
      end
    else
      @order.errors.add(:base, 'Can\'t find Paypal payment.')
      return false
    end
  end

  class << self
    def refund_info(refund_id)
      begin
        PayPal::SDK::REST::Refund.find(refund_id)
      rescue
      end
    end

    def get_sale_id(payment_id)
      begin
        payment = PayPal::SDK::REST::Payment.find(payment_id)
        if payment && payment.transactions && payment.transactions[0].related_resources
          payment.transactions[0].related_resources[0].sale.id
        end
      rescue
      end
    end
  end

  private

  def build_transaction
    transactions = {transactions: [{
            amount: {
              total: @order.price,
              currency: @order.currency
            },
            description: "order id: #{@order.id}"
          }]}
    return transactions
  end

  def error_msg(paypal_error)
    return paypal_error
  end

  def find_paypal_payment
    PayPal::SDK::REST::Payment.find(@payment_id)
  rescue PayPal::SDK::REST::ResourceNotFound => e
    @order.errors.add(:base, "Can't find paypal payment.")
    logger.error "PayPal payment not found with payment id #{@payment_id}"
    return false
  end
end
