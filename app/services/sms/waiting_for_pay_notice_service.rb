class Sms::WaitingForPayNoticeService
  attr_accessor :order, :sms_service

  def initialize(order_id)
    @order = Order.find(order_id)
    @sms_service = SmsService.new(provider: :sms_get)
    fail PaymentMethodNotAllowedError unless ['neweb/atm', 'neweb/mmk'].include? @order.payment
    fail PaymentStateError unless @order.waiting_for_payment?
    fail ServiceTypeError unless sms_service.respond_to?(:execute)
  end

  def execute
    result = sms_service.execute(format_phone, payment_content)
    if result[:status] =~ /ok/i
      order.create_activity(:send_sms, message: "簡訊內容:#{payment_content}")
    else
      order.create_activity(:send_sms_failed, message: result[:message])
    end
    { status: result[:status], message: result[:message] }
  end

  protected

  def payment_content
    price = order.price.ceil
    case order.payment
    when 'neweb/atm'
      msg = '您好，感謝您訂購“我印”客製化商品，您的繳款方式：銀行轉帳。請於繳費期限內完成付款，至ATM/網路銀行轉帳完成繳費，即可完成訂購手續。'
      msg += "您的訂單金額：#{price}元，您的轉帳代碼：007 第一銀行，繳費帳號：#{order.payment_id}，共16碼，謝謝您。"
    when 'neweb/mmk'
      msg = '您好，感謝您訂購“我印”客製化商品，您的繳款方式：超商繳費。請於繳費期限內完成付款。至超商選擇”ezPay 台灣支付”/“代碼輸入“，'
      msg += "完成繳費，即可完成訂購手續。您的訂單金額：#{price}元，您的繳費代碼：#{order.payment_id}，共16碼，謝謝您。"
    end
  end

  def format_phone
    phone = order.billing_info.phone
    phone.gsub!('+886','0') if phone.match(/\+886/)
    phone.gsub!('-','') if phone.match(/-/)
    phone
  end
end
