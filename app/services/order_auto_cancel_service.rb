# 訂單建立後6天要自動 Cancel
# Cancel 需要寫入動態 "付款時間過期系統自動取消訂單"
# API 在 Call Pay 的時候需要回傳 400 "該訂單由於超過付款期限已自動取消，請重新下單"

class OrderAutoCancelService
  def initialize
    @orders = Order.waiting_for_payment.before(6.day.ago.beginning_of_day)
  end

  # @return nothing
  def execute
    @orders.find_each do |order|
      order.cancel!
      order.create_activity(:expire_day_auto_cancel, source: { channel: 'worker' })
    end
  end
end
