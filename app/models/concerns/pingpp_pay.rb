module PingppPay
  extend ActiveSupport::Concern

  def pay
    free_checking || begin
      @order.logcraft_extra_info = to_hash
      @order.save.tap do
        @order.create_activity(:pay_ready)
      end
    end
  end

  def paid?
    false
  end
end
