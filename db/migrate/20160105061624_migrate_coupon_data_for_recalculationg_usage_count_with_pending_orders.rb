class MigrateCouponDataForRecalculationgUsageCountWithPendingOrders < ActiveRecord::Migration
  def change
    # 因二次付款延期先pending
    # orders = Order.where(aasm_state: 'pending').where.not(coupon_id: nil)
    # orders.find_each do |order|
    #   next if order.coupon.usage_count == 0
    #   order.coupon.decrement! :usage_count
    #   order.coupon.parent.decrement! :usage_count if order.coupon.parent.present?
    #   if order.coupon.blank?
    #     order.notes.create message: "清除綁定的coupon_id: #{order.coupon_id}，因為該coupon於資料庫不存在"
    #     order.update_column :coupon_id, nil
    #   elsif order.coupon.usage_count > 0
    #     order.coupon.decrement! :usage_count
    #     order.coupon.parent.decrement! :usage_count if order.coupon.parent.present?
    #   else
    #     next
    #   end
    # end
  end
end
