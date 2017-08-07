class PaymentDunService
  attr_accessor :order, :sms_service

  def initialize(order_id, sms_service)
    @order = Order.find order_id
    @sms_service = sms_service
    fail PaymentMethodNotAllowedError unless ['neweb/atm', 'neweb/mmk'].include? @order.payment
    fail PaymentStateError unless @order.waiting_for_payment?
    fail ServiceTypeError unless sms_service.respond_to?(:execute)
  end

  def execute
    result = sms_service.execute(order.billing_info.phone, payment_content)
    if result[:status] =~ /ok/i
      order.create_activity(:send_sms)
      order.update sms_job_id: nil
    else
      order.create_activity(:send_sms_failed, message: result[:message])
    end
    { status: result[:status], message: result[:message] }
  end

  protected

  def payment_content
    text = '『您好，提醒您訂購“我印”客製化商品，還未繳款，您的商品在等您把它領回家唷，'\
            '請儘速至ATM/超商繳納費用，繳款期限到期仍未繳款，系統將自動取消訂單。'
    case order.payment
    when 'neweb/atm'
      text + "您的繳款方式: 銀行代碼: #{order.payment_object.bank_id}, 付款帳戶: #{order.payment_id}，謝謝您』"
    when 'neweb/mmk'
      text + "您的繳款方式: 超商繳費, 繳費代碼: #{order.payment_id}，謝謝您』"
    end
  end
end
