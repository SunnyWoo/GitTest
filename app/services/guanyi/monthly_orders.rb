module Guanyi::MonthlyOrders
  def orders
    start_time = Time.zone.now.prev_month.beginning_of_month
    end_time = Time.zone.now.prev_month.end_of_month
    @orders ||= Order.shipping
                     .where(shipped_at: start_time..end_time)
                     .where('not order_data ? :key', key: 'guanyi_purchase_code')
  end
end
